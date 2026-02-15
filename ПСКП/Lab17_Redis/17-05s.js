const redis = require("redis");

const subscriber = redis.createClient({
    url: 'redis://localhost:6379'
});

subscriber.on('ready', () => console.log('ready'));
subscriber.on('error', (err) => console.log('error: ', err));
subscriber.on('connect', () => console.log('connected'));
subscriber.on('end', () => console.log('end'));


let start = async () => {
    try {

        await subscriber.connect();

        await subscriber.subscribe('TestChannel', (message) => {
            console.log(`Received message: ${message}`)
        });

        setTimeout(() => {
            subscriber.unsubscribe();
            subscriber.quit()
        }, 30000)

    }
    catch (err) {
        console.error('Error:', err);
    }
}

start();