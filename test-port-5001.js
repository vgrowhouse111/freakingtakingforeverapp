const http = require('http');

const server = http.createServer((req, res) => {
  console.log('Request received on port 5001:', req.method, req.url);
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from port 5001!');
});

const PORT = 5001;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Test server running on http://0.0.0.0:${PORT}`);
}).on('error', (err) => {
  console.error('Server error:', err);
});
