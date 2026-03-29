const http = require('http');

const PORT = 3000;

function sum(...args) {
  let result = 0;
  for (let i = 0; i < args.length; i++) {
    result += args[i];
  }
  return result;
}

function mul(...args) {
  let result = 1;
  for (let i = 0; i < args.length; i++) {
    result *= args[i];
  }
  return result;
}

function div(x, y) {
  if (y === 0) {
    throw new Error('Деление на ноль');
  }
  return x / y;
}

function proc(x, y) {
  if (y === 0) {
    throw new Error('Деление на ноль');
  }
  return (x / y) * 100;
}

// Словарь доступных методов
const methods = { sum, mul, div, proc };-

function handleRequest(body) {
  let request;
  try {
    request = JSON.parse(body);
  } catch (e) {
    return {
      jsonrpc: '2.0',
      error: { code: -32700, message: 'Parse error' },
      id: null
    };
  }

  if (!request.method || request.jsonrpc !== '2.0') {
    return {
      jsonrpc: '2.0',
      error: { code: -32600, message: 'Invalid Request' },
      id: request.id || null
    };
  }

  const method = methods[request.method];
  if (!method) {
    return {
      jsonrpc: '2.0',
      error: { code: -32601, message: 'Method not found: ' + request.method },
      id: request.id
    };
  }

  try {
    const params = request.params || [];
    const result = method(...params);

    return {
      jsonrpc: '2.0',
      result: result,
      id: request.id
    };
  } catch (e) {
    return {
      jsonrpc: '2.0',
      error: { code: -32000, message: e.message },
      id: request.id
    };
  }
}

const server = http.createServer((req, res) => {
  if (req.method !== 'POST') {
    res.writeHead(405, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Используйте метод POST' }));
    return;
  }

  let body = '';
  req.on('data', (chunk) => {
    body += chunk;
  });

  req.on('end', () => {
    const response = handleRequest(body);

    console.log('Запрос:', body);
    console.log('Ответ:', JSON.stringify(response));
    console.log('---');

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(response));
  });
});

server.listen(PORT, () => {
  console.log(`JSON-RPC сервер запущен на http://localhost:${PORT}`);
});