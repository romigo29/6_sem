
const crypto = require('crypto');

(async () => {

    const initRes = await fetch('http://localhost:3000/');
    const { sessionId, publicKey } = await initRes.json();


    const res = await fetch(`http://localhost:3000/resource?sessionId=${sessionId}`);

    if (!res.ok) {
        console.log("Ошибка:", res.status);
        return;
    }

    const { message, signature } = await res.json();


    const verify = crypto.createVerify('SHA256');
    verify.update(message);
    verify.end();

    const isValid = verify.verify(publicKey, signature, 'base64');

    console.log("Сообщение:", message);
    console.log("Подпись корректна:", isValid);
})();