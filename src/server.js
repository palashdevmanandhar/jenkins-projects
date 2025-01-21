// First, create a new file called server.js for the backend
const express = require('express');
const app = express();
const cors = require('cors');
const axios = require('axios');

app.use(cors());

app.get('/api/ip', async (req, res) => {
    try {
        const response = await axios.get('https://api.ipify.org?format=json');
        res.json({ ip: response.data.ip });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch IP' });
    }
});

app.listen(3001, () => {
    console.log('Backend server running on port 3001');
});