const router = require('express').Router();
const url = require('url');
const books = require('../lib/services/books');
module.exports = router;

router.get('/', function (req, res){
  res.json(books.findAll().map(formatBook));
});

router.get('/:id', function (req, res){
  let book = books.find(req.params.id)
  if(book){
    res.json(formatBook(book));
  }else{
    res.status(404).json({
      'message' : 'Not found'
    });
  }
});

function formatBook(book){
  //hide download path
  delete book.filepath;
  //fix cover path
  book.thumbnail = url.resolve('/covers/', book.thumbnail);
  return book;
}