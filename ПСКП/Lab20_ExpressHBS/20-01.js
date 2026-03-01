const express = require('express');
const fs = require('fs');
const path = require('path');
const { engine } = require('express-handlebars');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'phonebook.json');


app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));


app.engine('handlebars', engine({
    defaultLayout: 'main',
    helpers: {
        cancelButton: function () {
            return '<a href="/" class="btn">Отказаться</a>';
        }
    }
}));

app.set('view engine', 'handlebars');


function readData() {
    if (!fs.existsSync(DATA_FILE)) {
        fs.writeFileSync(DATA_FILE, '[]');
    }
    const data = fs.readFileSync(DATA_FILE);
    return JSON.parse(data);
}

function writeData(data) {
    fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
}




app.get('/', (req, res) => {
    const contacts = readData();
    res.render('index', { contacts });
});


app.get('/Add', (req, res) => {
    const contacts = readData();
    res.render('add', { contacts });
});


app.post('/Add', (req, res) => {
    const contacts = readData();
    const newId = contacts.length > 0 ? Math.max(...contacts.map(c => c.id)) + 1 : 1;

    contacts.push({
        id: newId,
        name: req.body.name,
        phone: req.body.phone
    });

    writeData(contacts);
    res.redirect('/');
});


app.get('/Update/:id', (req, res) => {
    const contacts = readData();
    const contact = contacts.find(c => c.id == req.params.id);

    res.render('update', { contacts, contact });
});


app.post('/Update', (req, res) => {
    const contacts = readData();
    const index = contacts.findIndex(c => c.id == req.body.id);

    if (index !== -1) {
        contacts[index].name = req.body.name;
        contacts[index].phone = req.body.phone;
    }

    writeData(contacts);
    res.redirect('/');
});


app.post('/Delete', (req, res) => {
    let contacts = readData();
    contacts = contacts.filter(c => c.id != req.body.id);

    writeData(contacts);
    res.redirect('/');
});

app.listen(PORT, () => {
    console.log(`Server started on port ${PORT}`);
});