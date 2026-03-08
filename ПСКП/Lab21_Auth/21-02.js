const express = require('express');
const passport = require('passport');
const DigestStrategy = require('passport-http').DigestStrategy;
const session = require('express-session');

const users = require('./users.json').users;

const app = express();

app.use(session({
    secret: 'secret',
    resave: false,
    saveUninitialized: false
}));

app.use(passport.initialize());
app.use(passport.session());


// стратегия DIGEST
passport.use(new DigestStrategy(
    { qop: 'auth' },

    function(username, done) {

        const user = users.find(u => u.username === username);

        if (!user) {
            return done(null, false);
        }

        return done(null, user, user.password);
    },

    function(params, done) {
        done(null, true);
    }
));


passport.serializeUser(function(user, done) {
    done(null, user.username);
});

passport.deserializeUser(function(username, done) {

    const user = users.find(u => u.username === username);

    done(null, user);
});


// проверка авторизации
function auth(req, res, next) {

    if (req.isAuthenticated()) {
        return next();
    }

    res.redirect('/login');
}


// LOGIN
app.get('/login',
    passport.authenticate('digest', { session: true }),
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


// остальные URI
app.use((req, res) => {
    res.status(404).send('404: resource not found');
});


app.listen(3000, () => {
    console.log('Server started on port 3000');
});