const path = require('path');
const fs = require('fs');
const session = require('express-session');
const cookieparser = require('cookie-parser');
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const flash = require('connect-flash');

let app = require('express')();

// add the passports js there and link it here. look up how i did it in scry, and examples below
// https://github.com/HackedByChinese/passport-examples/blob/master/example-simple/passport.js
// https://github.com/mjhea0/passport-social-auth/blob/master/server/app.js
// https://github.com/passport/express-4.x-local-example/blob/master/server.js

app.use(cookieparser());
app.use(session({
    secret: 'keyboard cat', // change this.
    resave: false,
    saveUninitialized: false,
    rolling: true,
    name: 'sid', // don't use the default session cookie name
    cookie: {
        httpOnly: true,
        // the duration in milliseconds that the cookie is valid
        maxAge: 20 * 60 * 1000, // 20 minutes
        // recommended you use this setting in production if you have a well-known domain you want to restrict the cookies to.
        // domain: 'your.domain.com',
        // recommended you use this setting in production if your site is published using HTTPS
        // secure: true,
    }
}));
app.use(flash());
passport.serializeUser((user, done) => {
    done(null, user._id);
});
passport.deserializeUser(function (userId, done) {
    db.User.findById(userId)
        .then(function (user) {
        done(null, user);
        })
        .catch(function (err) {
        done(err);
        });
});

passport.use(new LocalStrategy((username, password, done) => {
    const errorMsg = 'Invalid username or password';

    db.User.findOne({username})
        .then(user => { // if no matching user was found...
        if (!user) {
            return done(null, false, {message: errorMsg});
        }

        // call our validate method, which will call done with the user if the
        // passwords match, or false if they don't
        return user.validatePassword(password)
            .then(isMatch => done(null, isMatch ? user : false, isMatch ? null : { message: errorMsg }));
        })
        .catch(done);
}));

app.use(passport.initialize());
app.use(passport.session());

module.exports = app;