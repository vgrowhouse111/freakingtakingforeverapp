const http = require('http');

const server = http.createServer((req, res) => {
  console.log('Request received:', req.method, req.url);
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from simple server!');});

const PORT = 5000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Simple server running on http://0.0.0.0:${PORT}`);
});

// Handle errors
server.on('error', (err) => {
  console.error('Server error:', err);
});
