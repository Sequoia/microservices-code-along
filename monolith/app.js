const port = process.env.PORT || 8080;
// ^^ CONFIG ^^ //

const app = require('express')();
const static = require('express').static;
const {sessionSetup} = require('./lib/localAuth');
const authRouter = require('./routes/auth');
const paymentsRouter = require('./routes/payments');
const booksRouter = require('./routes/books');
const requireLogin = require('./lib/middleware/requireLogin');

app.use(sessionSetup);

app.use('/auth', authRouter);
app.use('/Books', booksRouter);
//require login for payment router
app.use('/buy', requireLogin, paymentsRouter);
//redirect index to our books router for book listing
app.get('/', (req, res) => res.redirect('/Books'));

//covers etc.
app.use('/download', requireLogin);
app.use(static('assets'));

app.listen(port, (err) => {
  if(err) throw err;
  console.log(`listening on port ${port}`);
  console.log(`(probably http://localhost:${port} )`);
})