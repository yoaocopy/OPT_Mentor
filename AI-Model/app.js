const express = require('express');
const path = require('path');
const cors = require('cors');
const app = express();
const port = 3000; 

// setting CORS
app.use(cors({
    origin: 'http://localhost:8888',
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use('/models/resolve/main/', express.static('./models/Llama-3.2-3B-Instruct-q4f16_1-MLC/'));
app.use('/libs/', express.static('./libs/'));


app.get('/', (req, res) => {
    res.send('Hello World!');
});

app.listen(port, () => {
    console.log(`Server running at http://127.0.0.1:${port}`);
});