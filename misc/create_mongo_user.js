const User = require('../lib/services/User');

// cleanup
async function createUser(){
  await User.remove({username: 'admin'});

  // create demo user
  await User.create({
    username : 'admin',
    password : 'secret'
  }); 

  // lookup user
  let user = await User.findOne({username: 'admin'});

  // log
  console.log(user);

  // check password
  if(user.checkPassword('secret')){
    console.log('password GOOD');
  }else{
    console.log('password BAD');
  }
}

createUser();
