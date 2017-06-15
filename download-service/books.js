'use strict';

const AWS = require('aws-sdk');
const s3 = new AWS.S3({params: { Bucket: process.env.BOOKS_BUCKET } });
const jwt = require('jsonwebtoken');
const kms = new AWS.KMS();

module.exports.download = (event, context, callback) => {
  const token = event.queryStringParameters ? event.queryStringParameters.token : null;

  if(!token){
    return callback(null, {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Token query parameter is required'
      })
    });
  }

  console.log(`looking up ${token}`);

  decrypt(process.env.JWT_SECRET)
    .then(function verifyToken(JWT_SECRET){
      try{
        let payload = jwt.verify(token, JWT_SECRET);
        console.log(`user (${payload.username}) is downloading (${payload.filename})`);
        return payload;
      }catch(e){
        console.error('token problem!');
        e.statusCode = 403;
        throw e;
      }
    })
    .then(payload => {
      return s3.getObject({
        Key: payload.filename
      }).promise()
    })
    .then(response => {
      console.log(response);
      return callback(null, {
        statusCode: 200,
        headers: {
          "Content-Type" : response.ContentType,
          "Content-Length" : response.ContentLength
        },
        body: response.Body.toString()
      });
    })
    .catch(err => {
      console.log(err);
      return callback(null, {
        statusCode: err.statusCode || 500,
        body: JSON.stringify({
          message: err.message,
        })
      });
    });

};


function decrypt(ciphertext){
  console.log(`decrypting ${ciphertext}`);

  return kms.decrypt({
    CiphertextBlob: Buffer(ciphertext, 'base64')
  })
  .promise()
  .then(data => String(data.Plaintext))
  .then(plaintext => {
    console.log(`decrypted: ${plaintext}`);
    return plaintext;
  })
  .catch(e => {
    console.error('decryption problem!');
    console.error(e);
    throw e;
  })
}