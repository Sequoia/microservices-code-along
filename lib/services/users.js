// In a secure setup we'd require a salt here too and pass it to bcrypt :)
const bcrypt = require('bcryptjs');
const _ = require('lodash');
const users = []; // in memory "database"
const assert = require('assert');

//create default user (hack):
createUser({
  username : "admin",
  password : "secret"
});

/**
 * 
 * @param {object} query - search parameters
 * @return {object} User
 */
function find(query){
  return user = _.find(users, query);
}

/**
 * 
 * @param {object} user 
 */
function createUser(user){
  assert(user.username);
  assert(user.password);

  //create new ID
  user.id = users.length + 1;

  //hash password
  user.password = bcrypt.hashSync(user.password, 2);

  //save
  console.log('created user', user);
  users.push(user);
  return user;
}

/**
 * 
 * @param {object} user 
 * @param {string} password 
 * @return {bool} true if credentials are correct
 */
function checkPassword(user, password){
  return bcrypt.compareSync(password, user.password);
}

module.exports = { find, create: createUser, checkPassword}