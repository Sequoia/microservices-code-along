const router = require('express').Router();
const books = require('../lib/services/books');
const url = require('url');
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET;
const DOWNLOAD_PATH = process.env.DOWNLOAD_PATH;
module.exports = router;

router.get('/:id', function (req, res){
  console.log('getting book');
  books.getDownloadPath(req.params.id)
    .then(function(apiResponse){
      let payload = {
        username: req.user.username,
        filename: apiResponse.body
      };
      let jwtOptions = {
        expiresIn: "2m"
      };
      return jwt.sign(payload, JWT_SECRET, jwtOptions);
    })
    .then(token => url.resolve(DOWNLOAD_PATH, `?token=${token}`))
    .then(path => res.redirect(path))
    .catch(e => res.status(404).json({'message': 'Cannot find that book for purchase!'}));
});