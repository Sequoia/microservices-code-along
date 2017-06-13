const url = process.env.MONGO_USER_URL;

const mongoose = require('mongoose');

mongoose.Promise = global.Promise;
mongoose.connect(url);

//handle connection error
mongoose.connection.on('error', function(e){
  console.error(e);
});

module.exports = mongoose;