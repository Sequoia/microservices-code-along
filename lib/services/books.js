// books "database"
const books = require('./data/books.json');
const url = require('url');
const _ = require('lodash');

/**
 * get all books
 * @return Object[]
 */
function findAll(){
  //clone to prevent original objects from being modified
  return _.cloneDeep(books);
}

/**
 * 
 * @param {Number} id 
 * @return Object book
 */
function find(id){
  let book = _.clone(_.find(books, { id : parseInt(id) }));
  console.log(book);
  return book;
}

function getDownloadPath(id){
  let book = find(id);
  console.log(book);
  if(book){
    return url.resolve('/download/', book.filepath);
  }
}

module.exports = {
  findAll, find, getDownloadPath
}