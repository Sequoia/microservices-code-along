'use strict';

module.exports = function(Books) {
  Books.prototype.getDownloadPath = function getDownloadPath(done){
    return done(null, this.filepath);
  };

  Books.remoteMethod(
    'prototype.getDownloadPath',
    {
      returns: {type: 'string', root: true},
      http: {path: '/getDownloadPath', verb: 'get'},
      description: 'Sends download path for book purchases'
    }
  );

  return Books;
};
