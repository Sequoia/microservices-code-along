ℹ️ *See [INSTRUCTIONS.md](INSTRUCTIONS.md) for notes on using this repository.*

# Step 12: Externalizing User Records

Hitherto, we've been using an in-memory user store. This is obviously not a robust solution, and we will fix it it this step!

In this step we'll create a mongo collection to store users, create a [mongoose](https://www.npmjs.com/package/mongoose) model to handle users from our application, and update our auth configuration to work with this new datasource.

## Goals

1.  Create Mongo database on mlab.com
    * Create an mlab account
    * Create a "MongoDB Deployment"
    * Create a "database user" for this deployment
    * **Note the password for that database user**
2.  Create a `User` model using the Mongoose ODM
    * Mongoose is tangential to this workshop, so we'll simply copy in our mongoose User model.
    * Create a default/admin user
3.  Update our `localAuth` to use the `User` model
4.  Add a secret & environment variable setting for `MONGO_USER_URL`
5.  Deploy and alias a new version of our `auth` service
6.  Check that login, logout, buy etc. still work

## Hints

* Mongoose methods are asynchronous and return promises: parts of our auth application that touch mongoose will need to be updated to work with promises.
* Although the `webapp` service uses the same `lib/localAuth`, it should not need to be redeployed, as it only uses the session checking portion, not the user lookup portion.
* `passport.serializeUser` needs to be updated to convert the Mongoose `User` model object to plain JSON: `user.toJSON()`

# Step 11: Now.sh Deployment Cleanup

Our deploy is starting to get complicated, so it's a good time to step back and reorganize. In this short step we will consolidate our env settings for easier sharing across services, set up some default alias rules so we don't have to edit our `alias-rules.json` each deploy, and set up an overarching alias configuration to tie our services together.

## Aliasing

Hitherto, in order to point an alias to our newest deployment of a service, we'd note the deployment ID and modify our rules file to match. Another approach to this is to encode the alias name in a file that lives in the project. `now` allows us to [set various configuration options in `now.json`](https://zeit.co/blog/now-json#`alias`-(string|array)). We'll set a `now.alias` property for our each service, allowing us run `now alias` after each deploy to link that alias to the latest deploy.

We'll set up an overarching alias rules file to tie all of our aliased applications together.

## Environment variables & secrets

In order to automatically include environment variables in our deployment, we can add a `env` object to `now.json` with the environment variables. We don't want to check our database passwords in with our code of course, so we'll use [secrets](https://zeit.co/docs/features/env-and-secrets) in our `now.json` and `now` will read our secret values into the environment at deploy time.

## Additional considerations

This setup does tie us (slightly) to `now.sh` as a platform, but any deployment environment/platform will require some platform-specific configuration. Furthermore, as this deals primarily with proxy rules & environment variables, everything is outside our code, so migrating to another platform should not require code-changes.

## Goals

1.  Store the following secrets with `now secret`
    1. `@redis-session-url`
    2. `@session-secret`
2.  Set `now` object in now.json for the following modules:
    1. Auth:
        * `alias` : `<yourname>-auth.now.sh`
        * `env` : `REDIS_SESSION_URL` (secret), `SESSION_SECRET` (secret)
    1. Monolith:
        * `alias` : `<yourname>-webapp.now.sh`
        * `name` : `webapp` (renaming this from monolith, which will be our top-level domain alias)
        * `env` : `REDIS_SESSION_URL` (secret), `SESSION_SECRET` (secret), `BOOKS_API` (copy from `.env`)
3.  Create an overarching `monolith-alias.json` file that passes through:
    1. `auth**` to `<yourname>-auth.now.sh`
    2. `Books**` to `<yourname>-books-api.mybluemix.net`
    3. everything else to `<yourname>-webapp.now.sh`
4.  Deploy & alias auth & webapp (**_don't_ use `-E`!**)
5.  Create top-level `<yourname>-monolith.now.sh` alias using `monolith-alias.json` rules
6.  Check that things still work!

## Hints

*   https://zeit.co/docs/features/env-and-secrets#securing-env-variables-using-secrets
    * `now secret add redis-session-url <your-value-here>`
*   `now.json` configuration: https://zeit.co/blog/now-json
*   The `now` CLI has [a bug wherein `.gitignore` in parent directories are not respected](https://github.com/zeit/now-cli/issues/667) at the time of this writing. Add `.npmignore` files to `auth` & `monolith` to get around this. The files should look like this:
    ```
    .env
    ```
*   Normally we'd track `now.json` in git, I have ignored it and added `now.json.example` files so my `sequoia-` aliases don't clobber your `<yourname>-` aliases.

# Step 10: Externalizing Authentication

In order to scale our main web app ("monolith") separately from authentication, we'll need to split authentication off as its own microservice. This presents a problem, however, vis-a-vis authentication: sessions are currently stored in memory and memory is not shared across processes (i.e. between webapp instances and our auth microservice instance). In order to share sessions across processes, we'll need to store our session information in an external data store. We'll use Redis for this.

We also need a way to share cookies across domains, i.e. between `xxx-monolith.now.sh` and `xxx-auth.now.sh`. This can be solved using now.sh aliases: by proxying calls from `xxx-monolith.now.sh/auth**` to `xxx-auth.now.sh`, the auth service will recieve the same cookies as the main (monolith) service.

The properties we'll need shared across instances/services are:

1.  The "session secret" (allowing sessions to be created/looked up the same way)
2.  The session store location (our redis server)

## Goals

1.  Create external redis instance to store sessions
    * pass location as `REDIS_SESSION_URL` environment variable
2.  Externalize session secret
    * pass as `SESSION_SECRET` environment variable
3.  Modify passport configuration to use a redis session store
4.  Split `auth` routes off as their own microservice
5.  Deploy new auth server and monolith server
6.  Alias `/auth**` routes on our monolith to our auth service
7.  Verify that the following routes work:
    * `/login.html`
    * `/auth/account`
    * `/Books/1`
    * `/buy/1`

## Hints

**This step is a doozy so it's advisable to check the diff against the next step and see what's changed**

*   https://redislabs.com/ offers free redis hosting
*   Our passport stuff is already (conveniently!) separate from our monolith, living in `/lib`. This will make it easier to share across services
*   Add `SESSION_SECRET` and `REDIS_SESSION_URL` to `.env` files for both services
*   Add `prestart` `check-env` checks
*   The following can simply be moved from `monolith` to `auth`:
    * `/routes/auth` (also move routing lines from `app.js`)
    * `lib` link can be copied to `auth`
    * `package.json.build` script can be copied to `auth/package.json`
    * `package.json.prestart` script can be copied to `auth/package.json`
*   We'll leave `assets/login.html` on the `monolith` because it's part of our "frontend" and not "login logic"
* `connect-redis` can be used (in `lib` package) to back sessions with Redis


# Step 9: Tying our Bluemix books API into our "monolith"

Currently, we have our books API running on bluemix and a standalone `now` alias pointing to it, but this alias isn't much use by itself. What we need is for our main application ("monolith") to know about the books API. The two things it needs to be able to do is:

1.  Proxy client requests to `/Books**` through to the books API
2.  Call the books API internally (for the `/buy` route)

Feature (2) is required, and feature (1) is useful because it allows us to present organize our microservices under a single domain, which wins us some performance gains and generally simplifies things for the client. In order to achieve these goals we'll need to update:

1. Alias settings (to pass `/Books**` through to a different location)
2. The `BOOKS_API` environment variable (for internal calls)

## Extra Feature: `check-env`

Because this is a small step, we'll add one more feature during this step that will help us catch issues during deployment. Our application relies on certain environment variables being set, without which our application may start but will fail to actually run. If our application won't run properly, it's best to bail out as early as possible. To this end, we'll add a `prestart` lifecycle script to check that the requisite environment variables are set and bail out if they aren't.

In our case, this is especially helpful to catch if we deploy using `now` and forget to pass `-E`. `now` runs `npm start` to start our application, and npm will automatically run a `prestart` script before running `start`, so this is a good place to put our environment variable check.

## Goals

1.  Update alias settings to pass through to Bluemix
2.  Update `BOOKS_API` to point to Bluemix
3.  Add a `prestart` script to check for `BOOKS_API` environment variable
4.  With new deployment, check that the following still work:
    1. `/Books`
    2. `/buy/1`

## Hints

* https://www.npmjs.com/package/check-env#cli-usage
* https://docs.npmjs.com/misc/scripts

## Solution

### Environment check

* `npm i -S check-env`
* in `package.json.scripts`: `"prestart" : "check-env BOOKS_API"`

### Bluemix proxying

* Update `.env` so it looks like [monolith/.env.example](monolith/.env.example)
* Redeploy (and note the new deployment URL)
* Update `alias-rules.json` so it looks like [monolith/alias-rules.json.example](monolith/alias-rules.json.example)
* `now alias --rules alias-rules.json <yourname>-monolith.now.sh`


### Alternate approach to proxying

Instead of pointing `BOOKS_API` directly to `mybluemix.net/Books`, we could point it to `<yourname>-monolith.now.sh`. Because calls to `<yourname>-monolith.now.sh/Books**` are proxied to `mybluemix.net`, the internal call still end up ultimately hitting our Bluemix API server. The advantage to this approach is that we could update our alias to point `/Books**` somewhere else and our internal calls would also go to the new address **without us having to redeploy with new ENV vars**. The request would work thus:

1.  Internally, `/buy` route calls `GET <yourname>-monolith.now.sh/Books/1/getDownloadPath`
2.  Now.sh reads alias for `<yourname>-monolith.now.sh/Books**`
3.  Now.sh passes the request through to `<yourname>-books-api.mybluemix.net/Books/1/getDownloadPath`

The disadvantage of this approach is that it's a bit more confusing, which is why we went with the more straightforward approach outlined above. :smile:

# Step 8: Deploying our books api to Bluemix

In addition to the api building and datasource configuring tools provided by API Connect, APIC integrates with IBM cloud platform (Bluemix) to make deploying there easy.

In this step, we'll deploy the application to bluemix using the APIC GUI, then create an alias on `now.sh` pointing to it. This will allow us to swap out the LoopBack API server running on `now.sh` with one running on Bluemix without the client (browser) knowing that anything has changed!

The Bluemix dashboard is a bit overwhelming, but we only need to set up a few things to prepare to deploy our API:

1. A "service"
2. An "app"

Navigate to https://console.ng.bluemix.net/dashboard/apps and log in to create a service and an app (possibly also an "org" and a "space" and a "product" 😄).

With that done, it should be possible to deploy our updated LoopBack app from the GUI run locally by running `apic edit` from the `books-api` directory.

## Goals

1. Deploy updated LoopBack application to bluemix
2. Create a new "route" for it in bluemix: `<yourname>-books-api.mybluemix.net`
3. Test that it works
4. Point `<yourname>-books-api.now.sh` to `<yourname>-books-api.mybluemix.net` using an alias rule on now.sh

## Hints

1. If the local API designer (launched via `apic edit`)  does not show you an organization when you click "publish" > "add IBM bluemix target", make sure you've set up a "service" and an "app" in the [bluemix dashboard](https://console.ng.bluemix.net/dashboard/apps) and try again
2. From the dashboard, on your app page: "Routes" > "Edit routes" & add a route under `mybluemix.net`
3. Make sure to set the appropriate environment variables! (sidebar > runtime > environment variables)
4. It's not possible to alias to external services using `now alias <external> <alias-name>`, but you *can* do it using a rules file.

## Solution

### Aliasing

1.  Create an alias rules json file like the one shown in [books-api/alias-rules.json.example](books-api/alias-rules.json.example)
2.  Deploy alias with `now alias --rules alias-rules.json <yourname>-books-api.now.sh`

# Step 7: Replacing our books router with the LoopBack API

So far, we've externalized our books API, but we haven't fully split that portion of the application off from the monolith: requests to `/Books` still pass through the Express `books` router on our monolith. We'll complete the process of splitting off this portion off the application by removing the book router and passing requests directly to the books API app.

We access our books api in two ways:

1. Via direct HTTP requests to `/Books` from clients
2. *Internally*, from our payments router

For (1), we can completely remove the books router & pass through to the LoopBack app, and our monolith doesn't need to be concerned with where this is. For (2), our monolith *does* still need to know where the books API is. We'll externalize the `BOOKS_API` URl so we can change it by environment but still access it from our payments router.

## Goals

1. Externalize `BOOKS_API` to an environment variable
    * Set it to point to our `<yourname>-books-api.now.sh` deployment
2. Deploy our updated monlith app to `now`
3. Set an alias rule on `monolith` that passes requests to `/Books**` through to `<yourname>-books-api.now.sh`
3. Set an alias rule on `monolith` that passes `<yourname>-monolith.now.sh` through to the most recently deployed instance of `monolith`
4. Remove the `books` router
    * Redeploy app & update `monolith` alias to point to new deployment

## Hints

* Once the `books` router is removed, it will no longer be possible to request that route on our locally running `monolith` application
* See [now docs](https://zeit.co/docs/features/path-aliases) for info on alias rules files. There should be two paths: one for `/Books**` and one for all other requests.
* [dotenv](https://www.npmjs.com/package/dotenv) makes it easy to load `.env` files locally

---

# Step 6: Deploying books API to `now`

In this step, we'll deploy our updated books API to `now`. Before doing so, we'll clean it up so we do not expose our database credentials. As you work with now, it will be useful to delete deployments you're no longer using, so be sure to `now rm <deployment|alias>` from time to time.

## Goals

1. Externalize database connection configuration
2. Deploy with environment variables (via `-E`)
3. Alias our books API as `<yourname>-books-api.now.sh`

## Hints

1. Externalizing database credentials will require two steps:
    1. Referring to environment variables from [loopback](https://loopback.io/doc/en/lb3/Attaching-models-to-data-sources.html#specifying-database-credentials-with-environment-variables)
    2. Setting those variables in the environment in which your app will run (e.g. [now](https://zeit.co/docs/features/env-and-secrets))


---

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