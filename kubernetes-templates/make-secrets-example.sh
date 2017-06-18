kubectl create secret generic books\
 --from-literal=JWT_SECRET="I've got a lovely bunch of coconuts"\
 --from-literal=REDIS_SESSION_URL="redis://<HOST>:<PORT>?password=<PASSWORD>"\
 --from-literal=SESSION_SECRET="keyboard cat"\
 --from-literal=MONGO_USER_URL="mongodb://<USER>:<PASS>@<HOST>:27531/auth-demo"
