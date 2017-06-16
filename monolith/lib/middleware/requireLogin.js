module.exports = function requireLogin(req, res, next){
  if(!req.user){
    console.log('not logged in!!');
    return res.status(403).json({
      'message' : 'please log in!!'
    });
  }
  else{
    next();
  }
};