const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const session = require('express-session');
const RedisStore = require('connect-redis')(session);
const User = require('../lib/services/User');

passport.use('local', new LocalStrategy(
  function localLogin(username, password, done) {
    User.findOne({ username: username }, function(err, user) {
      if (err) { return done(err); }
      if (!user) {
        return done(null, false, { message: 'Incorrect username.' });
      }
      if (!user.checkPassword(password)) {
        return done(null, false, { message: 'Incorrect password.' });
      }
      return done(null, user);
    });
  })
);

/**
 * // on successful login, this will set a cookie
 * @param {object} options - to pass to passport.authenticate
 * @param {string} options.successRedirect
 * @param {string} options.failureRedirect
 */
function loginRoute(options){
  return passport.authenticate('local', options);
}

// this allows saving just the user.id in the session then looking up
// the full user on each request. Our user record is small so we'll
// just put the whole user into the session (no serializing)
passport.serializeUser(function storeWholeUser(user, done){
    done(null, user.toJSON());
});

passport.deserializeUser(function returnWholeUser(user, done){
  done(null, user);
});

// on successful session lookup, this will set req.session.user
/**
 * `app.use` this to enable passport session handling
 * @type {Express.Middleware[]} requireLogin - array of middlewares that cause login to be required
 */

const sessionSetup = [
  session({
    store: new RedisStore({ url: process.env.REDIS_SESSION_URL }),
    secret: process.env.SESSION_SECRET,
    saveUninitialized : false,  // create session for non-logged-in users
    resave : false              // save back to session store for each request
  }),
  passport.initialize(),
  passport.session()
];

module.exports = {
  loginRoute, sessionSetup
}