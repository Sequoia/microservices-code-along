ℹ️ *See [INSTRUCTIONS.md](INSTRUCTIONS.md) for notes on using this repository.*

# Step 5: Update books service to point to LoopBack books API

We have now extracted our books API, but within our monolith application, we're still calling the local books in-memory "database" from our books and payments router. We'll fix that here so they point to the external API.

We'll use the `superagent` module to simplify sending HTTP requests

## Goals

1. Alter `services/books.js` so it calls our local LoopBack app (`http://localhost:3000/Books`)
   * This will require switching to an asynchronous (i.e. Promises based) API
1. Alter books router so it uses supports the new (promise based) books service
1. Alter payments router so it uses supports the new (promise based) books service
1. Test that routes still work
   * `/Books`
   * `/Books/2`
   * `/buy/2`

## Hints

* Your application server runs locally on port 8080
* The loopback server runs locally on port 3000

```js
const request = require('superagent');

request.get('http://example.com/foo.json')
  .then(response => {
    console.log(response.body); //superagent automatically parses JSON body
  })
  .catch(e => {
    console.error('connection error!');
  })
```

---

# Step 4: Customizing our models

In this step we'll add relationships to our models, hide some data by default, and add a remote method.

## Goals

1. Hide `filepath` from books response
2. Create relationships:
   1. Book belongsTo Author
   1. Book belongsTo Language
3. Return these related records by default
3. Create a `getDownloadPath` remote method on Books
0. Set root API path to `/` (instead of `/api`)
4. Run your API and test

## Hints

1. https://loopback.io/doc/en/lb2/Model-definition-JSON-file.html#hidden-properties
2. https://loopback.io/doc/en/lb3/BelongsTo-relations.html#defining-a-belongsto-relation
3. https://loopback.io/doc/en/lb3/Model-definition-JSON-file.html#default-scope
4. https://loopback.io/doc/en/lb3/Remote-methods.html#how-to-add-a-remote-method-to-a-model
   * Books.remoteMethod('prototype.getDownloadPath' ...

---

# Step 3: Creating Books API to a microservice

In this step we'll be splitting the `books` route into its own microservice, built on LoopBack/API Connect (apic). While LoopBack refers to the application framework  and APIC refers more broadly to IBM's API Connect tools (including LoopBack), the terms will be used interchangeably here.

For this step you'll need the [APIC command line tools installed](https://developer.ibm.com/apiconnect/getting-started/). You'll also need an account on IBM Bluemix to use the APIC GUI.

## Goals

1. Create LoopBack application scaffolding using the `apic` command line tool
2. Run the APIC GUI locally
2. Connect it to a database (create a database or use the one I offer)
3. Use the model generators to create models based on database tables
6. Run the API explorer and try out your books API
   * *You'll need to add a certificate exception in your browser for the explorer to work*

---

# Step 2: Deploying to NOW.sh

For this step, you'll need to have the [now client](https://zeit.co/download) installed. Upon your first deployment (the first time you run `now`) you'll be prompted to create an account. Free accounts are allowed 3 concurrent deployments (June 2017).

## Deploying

With the now client installed, deploying to `now.sh` is as easy as changing directories to the target directory and typing `now`.

Or *almost* that easy. Some things that worked locally might fail upon deployment.

## Goals

1. Deploy to `now`
2. Resolve any issues with the deployment
3. Test routes on your live deployment.

## Hints

* Now runs the following during a node app deployment:
  1. `npm install`
  2. `npm build`
  3. `npm start`
* `npm build` is run in case you have any *additional setup steps such as installing more dependencies*

## Solution

Our `lib` dependencies were not being installed. Adding a build script to go to that directory and install those deps before starting the application fixed this.

---

# Step 1: Monolith
## `01-Monolith`

This is our starting point. The application in the `monolith` directory is our all-on-one-server application that we will decompose into microservices over the course of this training.

The application has the following components/features:

1. **Books router**: Retrieves books from a database\* & serves JSON
1. **Payments router**: "Processes a payment" and sends the user a link to download a book
1. **Download router**: Takes a request for a book and sends that file (from the local filesystem) to the user.
1. **Auth router**: Allows users to log in and have a session cookie set on their browser. Also allows creation of new users\* (**deleted on server shutdown**).

This application is mostly **stubbed**. This means that while the API endpoints as well as login/logout will work, they don't actually connect to external databases: the "databases" are just JavaScript objects stored in memory, and therefor they will be destroyed upon shutting down the application.

In the interest of simplifying the code and focusing on features and infrastructure, this application **only serves JSON** (with the exception of login & register routes). It is possible to add template/html functionality but this introduces additional complexity and is by and large outside the scope of this training.

\* All "databases" are currently in memory mock databases.

## Goals

1. Get the application up and running
   * `npm start`
2. Try out API functionality
   1. `/books`
   2. `/books/{id}`
   3. `/buy/{id}`
   4. `/download/{path}`
   5. `/auth/register`
   6. `/auth/login`
   7. `/auth/logout`