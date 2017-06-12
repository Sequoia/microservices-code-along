const router = module.exports = new require('express').Router();
const {loginRoute} = require('../lib/localAuth');
const requireLogin = require('../lib/middleware/requireLogin');

//for user checking/cookie writing
const bodyParser = require('body-parser');
router.use(bodyParser.urlencoded({extended:false}));

// routes
router.get('/account', requireLogin, function accountJSON(req, res){
  res.json(req.user);
});

router.post('/login', loginRoute({
  successRedirect: '/auth/account',
  failureRedirect: '/login.html?loginFailed'
}));

router.get('/logout', (req, res) => {
  req.logout(); // exposed by passport, destroys LOGIN session (not whole session)
  // req.session.destroy(); to destroy entire session
  res.redirect('/');
});

//catchall
router.get('*', (req, res) =>{
  res.json({
    'loginPage' : '/login.html'
  });
})