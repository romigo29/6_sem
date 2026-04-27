const sql = require('mssql');
require('dotenv').config();

const dbName = process.env.DB_NAME;
const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    port: parseInt(process.env.DB_PORT, 10),
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function connectWithRetry(config, label) {
    const maxAttempts = 20;
    const retryDelayMs = 2000;
    let lastError;

    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
        try {
            const pool = await new sql.ConnectionPool(config).connect();
            if (attempt > 1) {
                console.log(`Connected to ${label} after ${attempt} attempts`);
            }
            return pool;
        } catch (error) {
            lastError = error;
            console.log(`Waiting for ${label}: attempt ${attempt} of ${maxAttempts}`);
            await sleep(retryDelayMs);
        }
    }

    throw lastError;
}

async function ensureDatabase() {
    const masterConfig = { ...config, database: 'master' };
    const appConfig = { ...config, database: dbName };

    const masterPool = await connectWithRetry(masterConfig, 'MSSQL master');
    try {
        await masterPool.request().query(`
            IF DB_ID(N'${dbName}') IS NULL
            BEGIN
                EXEC('CREATE DATABASE [${dbName}]')
            END
        `);
    } finally {
        await masterPool.close();
    }

    const appPool = await connectWithRetry(appConfig, `MSSQL ${dbName}`);
    try {
        await appPool.request().query(`
            IF OBJECT_ID(N'dbo.Celebrities', N'U') IS NULL
            BEGIN
                CREATE TABLE dbo.Celebrities (
                    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                    FullName NVARCHAR(50) NOT NULL,
                    Nationality NVARCHAR(2) NOT NULL,
                    ReqPhotoPath NVARCHAR(200) NULL
                )
            END
        `);
    } finally {
        await appPool.close();
    }
}

const poolPromise = ensureDatabase()
    .then(() => new sql.ConnectionPool({ ...config, database: dbName }).connect())
    .then(pool => {
        console.log('Connected to MSSQL');
        return pool;
    })
    .catch(err => {
        console.error('Database connection error:', err);
        process.exit(1);
    });

module.exports = { sql, poolPromise };
