'use strict';
const url = require('url');
const thumbnail_path = process.env.THUMBNAIL_PATH || '/covers/';

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

  Books.observe('loaded', function prependThumbnailPath(ctx, next) {
    // prepend thumbnail path
    ctx.data.thumbnail = url.resolve(thumbnail_path, ctx.data.thumbnail);
    next();
  });

  return Books;
};
