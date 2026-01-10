
const { time } = require('console');
const express = require('express');
const os = require('os');

const app = express();
const port = 3000;

// Create 3 Endpoints

// GET /    
app.get('/', (req, res) => {
  res.json({
    message: 'Infrastructure Working',
    hostname: os.hostname(),
    time: new Date().toISOString()
 });
});


// GET /health
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime_seconds: Math.floor(process.uptime()),
    hostname: os.hostname(),
    timestamp: new Date().toISOString()
  });
});

// GET /validate
app.get('/validate', (req, res) => {
  res.json({
    validation: 'PASSED',
    checks: {
      server: 'running',
      memory_mb: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
      uptime: process.uptime(),
      platform: os.platform()
    },
    timestamp: new Date().toISOString()
  });
});

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Validation app listening at http://localhost:${port}`);
});