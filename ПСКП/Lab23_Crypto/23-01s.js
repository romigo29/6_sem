
const express = require('express');
const crypto = require('crypto');

const app = express();
app.use(express.json());

const sessions = new Map();

const p = 23;
const g = 5;


function randomInt() {
    return Math.floor(Math.random() * 10) + 1;
}


app.get('/', (req, res) => {
    const a = randomInt();
    const A = (g ** a) % p;

    const sessionId = crypto.randomUUID();

    sessions.set(sessionId, { a, A, key: null });

    res.json({ p, g, A, sessionId });
});


app.post('/key', (req, res) => {
    const { sessionId, B } = req.body;

    const session = sessions.get(sessionId);

    if (!session || !B) {
        return res.sendStatus(409);
    }

    const { a } = session;

    const K = (B ** a) % p;

    session.key = K;

    res.json({ status: 'ok' });
});


app.get('/resource', (req, res) => {
    const { sessionId } = req.query;

    const session = sessions.get(sessionId);

    if (!session || !session.key) {
        return res.sendStatus(409);
    }

    const text = "Романов Игорь Вячеславович";

    const cipher = crypto.createCipheriv(
        'aes-256-cbc',
        crypto.createHash('sha256').update(String(session.key)).digest(),
        Buffer.alloc(16, 0)
    );

    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    res.send(encrypted);
});

app.listen(3000, () => console.log('Server running'));