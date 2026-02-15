const redis = require("redis");

const publisher = redis.createClient({
    url: 'redis://localhost:6379'
});

publisher.on('ready', () => console.log('ready'));
publisher.on('error', (err) => console.log('error: ', err));
publisher.on('connect', () => console.log('connected'));
publisher.on('end', () => console.log('end'));


let start = async () => {
    try {

        await publisher.connect();

        setTimeout(() => {
            const message = 'Hello!'
            publisher.publish('TestChannel', message)
            console.log('Sent message: ', message);

        }, 3000)

        setTimeout(() => {
            publisher.quit()
        }, 20000)


    }
    catch (err) {
        console.error('Error:', err);
    }
}

start();