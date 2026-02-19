const http = require('http');

const PORT = 40000;

let storedRequest = null;

function calculate(op, x, y) {
    switch (op) {
        case 'add': return x + y;
        case 'sub': return x - y;
        case 'mul': return x * y;
        case 'div': return y !== 0 ? x / y : null;
        default: return null;
    }
}

function sendJSON(res, statusCode, data) {
    res.writeHead(statusCode, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(data));
}

const server = http.createServer((req, res) => {

    if (req.url !== '/NGINX-test') {
        res.writeHead(404);
        return res.end(JSON.stringify({ error: "Not Found" }));
    }
    // ---------- GET ----------
    if (req.method === 'GET') {
        if (!storedRequest) {
            res.writeHead(404);
            return res.end();
        }

        const result = calculate(storedRequest.op, storedRequest.x, storedRequest.y);
        return sendJSON(res, 200, { ...storedRequest, result });
    }

    // ---------- POST / PUT ----------
    if (req.method === 'POST' || req.method === 'PUT') {
        let body = '';
        req.on('data', chunk => body += chunk.toString());
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                const result = calculate(data.op, data.x, data.y);
                if (result === null) {
                    res.writeHead(400);
                    return res.end();
                }

                if (req.method === 'POST') {
                    if (storedRequest) {
                        res.writeHead(409);
                        return res.end();
                    }
                    storedRequest = { op: data.op, x: data.x, y: data.y };
                    return sendJSON(res, 200, { ...storedRequest, result });
                }

                if (req.method === 'PUT') {
                    if (!storedRequest) {
                        res.writeHead(404);
                        return res.end();
                    }
                    storedRequest = { op: data.op, x: data.x, y: data.y };
                    return sendJSON(res, 200, { ...storedRequest, result });
                }

            } catch (err) {
                res.writeHead(400);
                res.end();
            }
        });
        return;
    }

    // ---------- DELETE ----------
    if (req.method === 'DELETE') {
        if (!storedRequest) {
            res.writeHead(404);
            return res.end();
        }
        storedRequest = null;
        res.writeHead(200);
        return res.end();
    }

    res.writeHead(405);
    res.end();

});

server.listen(PORT, () => console.log(`Node.js server running on port ${PORT}`));
