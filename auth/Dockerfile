FROM node:7

# set port
ENV PORT 80

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . /usr/src/app
RUN npm run build

# replace this with your application's default port
EXPOSE $PORT

CMD npm start

# Example build:
# docker build -t you/books-auth .
# Example run:
# docker run --name books-auth -p 8091:80 -d --env-file=.env you/books-auth
