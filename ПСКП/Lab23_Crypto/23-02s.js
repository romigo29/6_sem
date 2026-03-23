
const express = require('express');
const crypto = require('crypto');

const app = express();

const sessions = new Map();


const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
});


app.get('/', (req, res) => {
    const sessionId = crypto.randomUUID();

    sessions.set(sessionId, { used: false });

    res.json({
        sessionId,
        publicKey: publicKey.export({ type: 'pkcs1', format: 'pem' })
    });
});


app.get('/resource', (req, res) => {
    const { sessionId } = req.query;

    const session = sessions.get(sessionId);

    if (!session || session.used) {
        return res.sendStatus(409);
    }

    const message = "Романов Игорь Вячеславович";


    const sign = crypto.createSign('SHA256');
    sign.update(message);
    sign.end();

    const signature = sign.sign(privateKey, 'base64');

    session.used = true;

    res.json({ message, signature });
});

app.listen(3000, () => console.log('Server started'));