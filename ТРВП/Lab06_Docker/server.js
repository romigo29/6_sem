const express = require('express');
const cors = require('cors');
require('dotenv').config();

const celebritiesRouter = require('./celebrities');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.json({ app: 'TDWA06-01', status: 'running' });
});

app.use('/api/celebrities', celebritiesRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server started on http://0.0.0.0:${PORT}`);
});
