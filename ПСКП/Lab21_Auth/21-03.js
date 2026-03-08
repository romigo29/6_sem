const express = require('express');
const session = require('express-session');

const users = require('./users.json').users;
const auth = require('./authMiddleware');

const app = express();

app.use(express.urlencoded({ extended: true }));

app.use(session({
    secret: 'secret',
    resave: false,
    saveUninitialized: false
}));


// страница формы логина
app.get('/login', (req, res) => {

    res.send(`
        <h2>Login</h2>
        <form method="POST" action="/login">
            <input name="username" placeholder="username"/><br>
            <input name="password" type="password" placeholder="password"/><br>
            <button type="submit">Login</button>
        </form>
    `);

});


// обработка формы
app.post('/login', (req, res) => {

    const { username, password } = req.body;

    const user = users.find(
        u => u.username === username && u.password === password
    );

    if (user) {

        req.session.user = user;

        res.redirect('/resource');

    }
    else {

        res.send('Invalid login or password');

    }

});


// logout
app.get('/logout', (req, res) => {

    req.session.destroy(() => {

        res.send('Logout success');

    });

});


// защищенный ресурс
app.get('/resource', auth, (req, res) => {

    res.send('RESOURCE');

});


// остальные URI
app.use((req, res) => {

    res.status(404).send('404: resource not found');

});


app.listen(3000, () => {

    console.log('Server started on port 3000');

});