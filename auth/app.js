require('dotenv').config();
const port = process.env.PORT || 8090;
// ^^ CONFIG ^^ //

const express = require('express');

const app = express();
const {sessionSetup} = require('./lib/localAuth');
const authRouter = require('./routes/auth');
const requireLogin = require('./lib/middleware/requireLogin');

app.use(sessionSetup);

app.use('/auth', authRouter);
app.get('/', (req, res) => res.redirect('/auth'));

app.listen(port, (err) => {
  if(err) throw err;
  console.log(`listening on port ${port}`);
  console.log(`(probably http://localhost:${port} )`);
})