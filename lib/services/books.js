const url = require('url');

// External books API
const request = require('superagent');
const makeUrl = path => url.resolve(BOOKS_API, path);
const BOOKS_API = process.env.BOOKS_API;

/**
 * get all books
 * @return {Promise<Object[]>}
 */
function findAll(){
  return request.get(makeUrl(''))
    .then(res => res.body);
}

/**
 * 
 * @param {Number} id 
 * @return {Promise<Object>} book
 */
function find(id){
  return request.get(makeUrl(id))
    .then(res => res.body);
}

function getDownloadPath(id){
  return request.get(makeUrl(`${id}/getDownloadPath`))
    .then(res => url.resolve('/download/', res.body));
}

module.exports = {
  findAll, find, getDownloadPath
}