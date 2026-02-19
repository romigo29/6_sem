import { useState } from 'react';
import './App.css';

function App() {
  const [op, setOp] = useState('');
  const [x, setX] = useState('');
  const [y, setY] = useState('');
  const [result, setResult] = useState('');

  const handleFetch = async (method) => {
    const url = "/api/Save-JSON";
    const data = method === "GET" || method === "DELETE" ? null : { op, x: Number(x), y: Number(y) };

    try {
      const response = await fetch(url, {
        method,
        headers: data ? { "Content-Type": "application/json" } : undefined,
        body: data ? JSON.stringify(data) : undefined
      });

      const text = await response.text();
      let json;
      try {
        json = text ? JSON.parse(text) : {};
      } catch {
        json = { error: text };
      }

      setResult(JSON.stringify(json, null, 2));
    } catch (err) {
      setResult("Ошибка: " + err);
    }
  };

  return (
    <div className="App">
      <h1>API Test TDWA02-02</h1>

      <div className="controls">
        <button onClick={() => handleFetch("GET")}>GET</button>

        <div>
          <input type="text" placeholder="Operation" value={op} onChange={e => setOp(e.target.value)} />
          <input type="number" placeholder="x" value={x} onChange={e => setX(e.target.value)} />
          <input type="number" placeholder="y" value={y} onChange={e => setY(e.target.value)} />
          <button onClick={() => handleFetch("POST")}>POST</button>
          <button onClick={() => handleFetch("PUT")}>PUT</button>
        </div>

        <button onClick={() => handleFetch("DELETE")}>DELETE</button>
      </div>

      <pre>{result}</pre>
    </div>
  );
}

export default App;
