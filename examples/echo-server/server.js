// Simple WebSocket echo server for testing the module (port 8080).
//   npm install && node server.js
// Sending the text "BIG <n>" makes the server answer with n characters
// (used to test reassembly of large messages and the MAX_MSG limit).
const { WebSocketServer } = require('ws');
const wss = new WebSocketServer({ port: 8080, host: '0.0.0.0', maxPayload: 1 << 20 });
wss.on('connection', (ws, req) => {
  console.log('connected:', req.socket.remoteAddress);
  ws.on('message', (data, isBinary) => {
    const m = !isBinary && /^BIG (\d+)$/.exec(data.toString());
    if (m) { console.log('sending large message:', m[1]); ws.send('x'.repeat(+m[1])); return; }
    console.log('received:', data.length, 'bytes', isBinary ? '(binary)' : '(text)');
    ws.send(data, { binary: isBinary });
  });
  ws.on('close', (code) => console.log('closed, code', code));
  ws.on('error', (e) => console.log('error:', e.message));
});
console.log('echo server on port 8080');
