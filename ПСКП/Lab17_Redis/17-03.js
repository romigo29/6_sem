const redis = require("redis");

const client = redis.createClient({
    url: 'redis://localhost:6379'
});

client.on('ready', () => console.log('ready'));
client.on('error', (err) => console.log('error: ', err));
client.on('connect', () => console.log('connected'));
client.on('end', () => console.log('end'));


let start = async () => {
    try {

        await client.connect();

        let startTime = Date.now();
        for (let i = 0; i < 10000; i++) {
            await client.incr('incr');
        }
        let endTime = Date.now();
        console.log(`Incr: ${endTime - startTime}ms`);


        startTime = Date.now();
        for (let i = 0; i < 10000; i++) {
            await client.decr('decr');
        }
        endTime = Date.now();
        console.log(`Decr: ${endTime - startTime}ms`);

    }
    catch (err) {
        console.error('Error:', err);
    } finally {
        await client.quit();
    }
}

start();