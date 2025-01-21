// First, create a new file called server.js for the backend
const express = require('express');
const app = express();
const cors = require('cors');

app.use(cors());

app.get('/api/ip', (req, res) => {
    // Get the server's public IP
    const serverIP = req.socket.localAddress;
    res.json({ ip: serverIP });
});

app.listen(3001, () => {
    console.log('Backend server running on port 3001');
});