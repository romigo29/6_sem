const express = require('express');
const passport = require('passport');
const BasicStrategy = require('passport-http').BasicStrategy;
const session = require('express-session');

const users = require('./users.json').users;

const app = express();

// session
app.use(session({
    secret: 'secret',
    resave: false,
    saveUninitialized: false
}));

app.use(passport.initialize());
app.use(passport.session());


// BASIC strategy
passport.use(new BasicStrategy(
    function(username, password, done) {

        const user = users.find(
            u => u.username === username && u.password === password
        );

        if (!user) {
            return done(null, false);
        }

        return done(null, user);
    }
));


passport.serializeUser(function(user, done) {
    done(null, user.username);
});

passport.deserializeUser(function(username, done) {

    const user = users.find(u => u.username === username);

    done(null, user);
});


// middleware проверки авторизации
function auth(req, res, next) {

    if (req.isAuthenticated()) {
        return next();
    }

    res.redirect('/login');
}


// LOGIN
app.get('/login',
    passport.authenticate('basic', { session: true }),
    (req, res) => {
        res.send('Login success');
    }
);


// LOGOUT
app.get('/logout', (req, res) => {

    req.logout(function() {
        res.send('Logout success');
    });

});


// RESOURCE
app.get('/resource', auth, (req, res) => {

    res.send('RESOURCE');

});


// 404
app.use((req, res) => {
    res.status(404).send('404: resource not found');
});


app.listen(3000, () => {
    console.log('Server started on port 3000');
});