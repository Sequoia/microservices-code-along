const router = require('express').Router();
const books = require('../lib/services/books');
module.exports = router;

router.get('/:id', function (req, res){
  console.log('getting book');
  books.getDownloadPath(req.params.id)
    .then(path => res.redirect(path))
    .catch(e => res.status(404).json({'message': 'Cannot find that book for purchase!'}));
});