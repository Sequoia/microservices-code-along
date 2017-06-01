const router = require('express').Router();
const books = require('../lib/services/books');
module.exports = router;

router.get('/:id', function (req, res){
  console.log('getting book');
  let book = books.find(req.params.id);

  if(!book){
    return res.status(404).json({'message': 'Cannot find that book for purchase!'});
  }

  //process payment...
  console.log(`'${req.user.username}' has purchased '${book.title}'`)
  //end process payment...

  res.redirect(books.getDownloadPath(req.params.id));

});