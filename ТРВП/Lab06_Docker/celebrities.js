const express = require('express');
const { sql, poolPromise } = require('./db');

const router = express.Router();

function parseId(value) {
    const id = Number.parseInt(value, 10);
    return Number.isInteger(id) && id > 0 ? id : null;
}

function validateCelebrity(body) {
    const errors = [];

    if (typeof body.FullName !== 'string' || body.FullName.trim() === '' || body.FullName.length > 50) {
        errors.push('FullName is required and must be up to 50 characters.');
    }

    if (typeof body.Nationality !== 'string' || body.Nationality.length !== 2) {
        errors.push('Nationality is required and must contain 2 characters.');
    }

    if (
        body.ReqPhotoPath !== undefined &&
        body.ReqPhotoPath !== null &&
        (typeof body.ReqPhotoPath !== 'string' || body.ReqPhotoPath.length > 200)
    ) {
        errors.push('ReqPhotoPath must be null or a string up to 200 characters.');
    }

    return errors;
}

router.get('/', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .query('SELECT Id, FullName, Nationality, ReqPhotoPath FROM Celebrities ORDER BY Id');

        res.json(result.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/:id', async (req, res) => {
    const id = parseId(req.params.id);
    if (!id) {
        return res.status(400).json({ error: 'Invalid id.' });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT Id, FullName, Nationality, ReqPhotoPath FROM Celebrities WHERE Id = @id');

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Celebrity not found.' });
        }

        res.json(result.recordset[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', async (req, res) => {
    const errors = validateCelebrity(req.body);
    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    const { FullName, Nationality, ReqPhotoPath } = req.body;

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('FullName', sql.NVarChar(50), FullName.trim())
            .input('Nationality', sql.NVarChar(2), Nationality.toUpperCase())
            .input('ReqPhotoPath', sql.NVarChar(200), ReqPhotoPath || null)
            .query(`
                INSERT INTO Celebrities (FullName, Nationality, ReqPhotoPath)
                OUTPUT INSERTED.Id, INSERTED.FullName, INSERTED.Nationality, INSERTED.ReqPhotoPath
                VALUES (@FullName, @Nationality, @ReqPhotoPath)
            `);

        res.status(201).json(result.recordset[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.put('/:id', async (req, res) => {
    const id = parseId(req.params.id);
    if (!id) {
        return res.status(400).json({ error: 'Invalid id.' });
    }

    const errors = validateCelebrity(req.body);
    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    const { FullName, Nationality, ReqPhotoPath } = req.body;

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('FullName', sql.NVarChar(50), FullName.trim())
            .input('Nationality', sql.NVarChar(2), Nationality.toUpperCase())
            .input('ReqPhotoPath', sql.NVarChar(200), ReqPhotoPath || null)
            .query(`
                UPDATE Celebrities
                SET FullName = @FullName,
                    Nationality = @Nationality,
                    ReqPhotoPath = @ReqPhotoPath
                OUTPUT INSERTED.Id, INSERTED.FullName, INSERTED.Nationality, INSERTED.ReqPhotoPath
                WHERE Id = @id
            `);

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Celebrity not found.' });
        }

        res.json(result.recordset[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.delete('/:id', async (req, res) => {
    const id = parseId(req.params.id);
    if (!id) {
        return res.status(400).json({ error: 'Invalid id.' });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM Celebrities OUTPUT DELETED.Id WHERE Id = @id');

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Celebrity not found.' });
        }

        res.status(200).send();
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
