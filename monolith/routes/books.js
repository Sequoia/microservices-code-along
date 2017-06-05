const router = require('express').Router();
const url = require('url');
const books = require('../lib/services/books');
module.exports = router;

router.get('/', function (req, res){
  books.findAll()
    .then(response => {
      res.json(response);
    });
});

router.get('/:id', function (req, res){
  books.find(req.params.id)
    .then(book => {
      res.json(book);
    })
    .catch(() => {
      res.status(404).json({
        'message' : 'Not found'
      });
    });
});