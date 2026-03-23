const crypto = require('crypto');
const fs = require('fs');


function randomInt() {
    return Math.floor(Math.random() * 10) + 1;
}

(async () => {

    const initRes = await fetch('http://localhost:3000/');
    const { p, g, A, sessionId } = await initRes.json();


    const b = randomInt();
    const B = (g ** b) % p;
    const K = (A ** b) % p;

    await fetch('http://localhost:3000/key', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sessionId, B })
    });


    const res = await fetch(`http://localhost:3000/resource?sessionId=${sessionId}`);

    if (!res.ok) {
        throw new Error(`Ошибка: ${res.status}`);
    }

    const encrypted = await res.text();

    const decipher = crypto.createDecipheriv(
        'aes-256-cbc',
        crypto.createHash('sha256').update(String(K)).digest(),
        Buffer.alloc(16, 0)
    );

    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    fs.writeFileSync('result.txt', decrypted);

    console.log('Расшифровано:', decrypted);
})();