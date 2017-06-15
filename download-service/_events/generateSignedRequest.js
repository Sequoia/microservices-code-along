const jwt = require('jsonwebtoken');
// hardcoded for simplicity:
const SECRET = "I've got a lovely bunch of coconuts";

const token = jwt.sign(
  { username: 'admin', filename: "Aces_Up.txt" },
  SECRET,
  { expiresIn : "2m"}
)

const event = {
  queryStringParameters : {
    token : token
  }
};

process.stdout.write(JSON.stringify(event));