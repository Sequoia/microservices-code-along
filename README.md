ℹ️ *See [INSTRUCTIONS.md](INSTRUCTIONS.md) for notes on using this repository.*

# Step 16: Dockerizing Webapp

This step is about the same as last step, but this time we're dockerizing `monolith`.

## Goals

1. Create docker image of `monolith`
2. Run it locally
3. Deploy it to `now.sh`
4. Alias the `now.sh` deploy and test that `/buy/2` still works

## Hints

*   Remember to update your `.env` file to remove wrapping quotes and escapes as before!
*   Remember to replace the `lib` link with a copy of `lib` as before!
*   Remember to pass `--docker` to `now` so it knows it's a docker image (because we have a `package.json` *and* dockerfile we need to tell it which type of build to use)
*   Example build command: `docker build -t you/webapp .`
*   Example run command: `docker run --name webapp -p 8090:80 -d --env-file=.env you/webapp`
*   Test it locally: `curl localhost:8090/login.html` should return the login page

# Step 15: Dockerizing Auth App

We've got our application stack running on `now.sh` directly using the Node runtime, but if we want the flexibility to ship to different providers it would be useful to dockerize our services. Now.sh supports the Node runtime directly, but it can also run docker images, allowing us to use whatever runtime we want. In this step we'll create a Dockerfile to run our `auth` service, run it locally, then ship it to `now.sh`.

## Goals

1. Create docker image of `auth`
2. Run it locally
3. Deploy it to `now.sh`
4. Alias the `now.sh` deploy and test that login still works

## Hints

* Docker `run` takes a `--env-file=.env` argument, but **it parses env files differently than the shell does!**
    *   Remove all wrapping quotes and escape characters for the `.env` file to work with `docker run --env-file=.env`
        ```ini
        # before:
        # SESSION_SECRET='keyboard cat'
        # update to:
        SESSION_SECRET=keyboard cat
        ```
* Docker cannot include directories outside the `CWD` in which you run `docker build`, so it cannot follow the `./lib` link to `../lib`
    *   The proper solution here is to externalize `lib` to an NPM package included by those services which need it.
    *   For the purpose of expediency, in our case we'll simply remove the `auth/lib` link and copy the `lib` directory into `auth`
        ```sh
        cd auth
        rm lib
        cp -r ../lib .
        ```

*   Our `Dockefile` will need to run `npm run build` explicitly since we're no longer relying on `now`s node startup process. Example:
    ```Dockerfile
    # Bundle app source
    COPY . /usr/src/app
    # After source is copied, run `npm run build`
    RUN npm run build
    ```

*   Example build command: `docker build -t <you>/books-auth .`
*   Example run command: `docker run --name books-auth -p 8091:80 -d --env-file=.env <you>/books-auth`
    * forwards local port 8091 to port 80 on the docker image
*   Test it locally: `curl localhost:8091/auth/account` should return a "please login" message
*   Add a `.dockerignore` file to avoid copying `**/node_modules`, `**/npm-debug.log`, `**/.env` and whatever other files are not needed for the image.

# Step 14d: Generating JWTs on our "webapp" server

Our lambda is now verifying JWTs, but we need some way for users to generate them. Currently, the "buy" on our webapp server (in the `monolith` directory) does the following:

1.  Checks if a user is logged in
2.  Passes the request to the `payments` router which...
2.  Calls `getDownloadPath` on the `books` service, which...
    1.  Gets the filename from our LoopBack books API server via the `getDownloadPath` remote method and...
    2.  Prepends `/download/` before returning the path to the payments router which...
3.  Sends a `Location` header to the client using Express's `res.redirect` method

We need to alter the behavior in the following ways:

1.  Replace the base download path (`/download/`) with the path to our `download` serverless function endpoint
    * We can externalize `DOWNLOAD_PATH` as an environment variable, just as we did with `THUMBNAIL_PATH`
2.  Replace the file path (`/download/${filepath}`) with a querystring `?token=<JWT Token>`
    * The payments router will need `jsonwebtoken` installed & to have *the same* `JWT_SECRET` available
    * The token should contain `username`, `filename`, and be set to expire in 2 minutes

## Goals

1.  `GET <yourname>-monolith.now.sh/buy/1` redirects (logged in) users to our lambda with a valid token
2.  Client experience is effectively the same as before
3.  Download link no longer works after 2 minutes
4.  Deploy to `now.sh` & verify functionality

## Hints


*   Building the download path (`/download/${filename}`) is currently handled in the `books` service, but we'll need to move that logic to the payments router so we have access to the username on request object. We need the username & filename to generate the token.
*   Our webapp needs **the same** `JWT_SECRET` in order to generate tokens that our download service will consider valid. This shared secret is the stateless "link" between the two services.
*   Testing authentication locally is tricky without the aliasing that links the auth & webapp microservices that we have on now. Here is a workaround:
    1. Run your auth server locally via `node app.js` (it will run on `localhost:8090`)
    2. Edit `monolith/assets/login.html` so the form `action=localhost:8090/auth/login`
    3. Start your webapp service
    4. Navigate to `localhost:8080/login.html` and log in
    
    You now have a valid session! You can undo the changes in `login.html`. Note that your session will continue to be valid on `localhost` (until it expires) as long as you don't hit the `auth/logout` route, *even if you shut down one or the other local server*. How this works is an exercise left to the reader!

*   A user record (`req.user`) looks like this:
    ```json
    {
        _id: '593f2453a89fbc64c3a84b70',
        username: 'admin',
        password: '$2a$04$WjYPkwmKu50huWBzqzbble1DemQ/xI8tQcTZOXMi1E2YNQA8W0uFq',
        __v: 0
    }
    ```
* Refer to `download_service/_events/generateSignedRequest.js` for `jsonwebtoken` usage example.

# Step 14c: Encrypting our JWT Secret

We do not want to write our plaintext JWT secret and commit it to our source code repository, as it may fall into the wrong hands that way! In this step we'll encrypt our JWT secret so it can safely be committed to our git repository, pass the encrypted secret to our Lambda, then decrypt it on the Lambda. But how will we handle the encryption keys so they are accessible to us (to encrypt values) and on our Lambda (to decrypt them)?

AWS offers a "Key Management Service" to handle encryption and decryption, for example in a Lambda. There's also a serverless plugin that allows us to the same key to encrypt values locally on our machine. We'll use this plugin ([`serverless-kms-secrets`](https://www.npmjs.com/package/serverless-kms-secrets)) to encrypt locally, store the values, and decrypt on lambda so our JWT_SECRET stays secret!

Before we can use this tool to encrypt locally, we'll need to:
1.  [Create a KMS key](https://console.aws.amazon.com/iam/home#/encryptionKeys/us-west-2)
2.  Give our `serverless-admin` AWS user access to it
4.  Install `serverless-kms-secrets` locally to our project
5.  Add `- serverless-kms-secrets` to the top level `plugins:` property in our `serverless.yaml`
3.  Copy the key id for the first time we run `sls encrypt`
6.  Add `kmsSecrets: ${file(kms-secrets.${opt:stage, self:provider.stage}.${opt:region, self:provider.region}.yml)}` to our top level `custom` property in our `serverless.yaml`

## Goals

1.  Create a yaml file with our encrypted `JWT_SECRET`
2.  Grant our function access to the `KMS:Decrypt` action with this key
3.  Alter the `download` function to decrypt the `JWT_SECRET` before verifying our token

## Hints

*   Key decryption is asynchronous and also has a `.promise()` method
    ```js
      const kms = new AWS.KMS();
      kms.decrypt({
        CiphertextBlob: Buffer(process.env.FOO_BAR, 'base64')
      })
      .promise()
      .then(data => String(data.plaintext))
      .then(plaintext => console.log(`here's the secret: ${plaintext}`))
    ```

*   Add this function to `books.js` to simplify decryption:

    ```js
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
    ```

# Step 14b: Gating Downloads with JWT

Now that our download-service Lambda is can read files out from S3, we'll add authentication. In order to allow it to authenticate requests statelessly we'll use JWTs. Using JWTs will allow us to verify the validity of download requests on our Lambda without relying on a session an external database. This way, we can create signed, dated requests somewhere else (anywhere else!) and verify them on our Lambda.

The one value that needs to be shared across the JWT creator & JWT verifier is the secret used to sign the token. We'll pass this to our Lambda as an environment variable: `JWT_SECRET`.

## Goals

1.  Read an encoded JWT via the `token` query string parameter.
2.  Decode & verify the token
3.  If valid, extract the filename & send that file to the user
4.  If not valid, send an error response

## Hints

*   `_events/generateSignedRequest.js` will create a dummy request object with a valid token
    * The `jsonwebtoken` npm package must be added to our `download-service` package before this will work
    * To try it: `node _events/generateSignedRequest | sls invoke local -f download`
*   Our `JWT_SECRET` ("I've got a lovely bunch of coconuts") can be hardcoded in our service configuration file for now, we'll fix that next step.
*   `npm init -y` in our `download-service` to allow tracking of module dependencies
*   To test it on the deployed server:
    1.  run `node _events/generateSignedRequest`
    2.  copy the `token` property
    3.  append it to your deployment URL: `?token=<the token you copied>`

# Step 14a: Removing Assets: Downloads

We will now remove our `downloads` directory to an S3 bucket as well, but because we want to restrict access to these assets, we'll need some authorization checks in front of it. We'll put them therefor in a bucket we *do not* expose over HTTP, but instead, expose through a Lambda. That will allow us to check download authorization before sending them the file. We'll save authorization for next step. In this step we'll get our Lambda set up, taking requests over HTTP, reading files from S3, and sending them back to the user.

This is a rather large step, so you're encouraged to refer to the finished version as needed. (Of course you can always do this as desired!).

:information_source: This step assumes you've already got serverless up and running and deployed a "hello world" service.

## Goals

1.  Create an S3 bucket for Downloads
2.  Create a "serverless" function that:
    1.  Takes a filename as a query parameter (`?token=filename.txt`)
    2.  Reads the file from S3
    3.  Sends it back to the user
3.  Time allowing: handle 403s, 404s, & 500 errors

## Hints

*   Create the S3 bucket (`books-downloads`) in the same region for simplicity (`us-west-2` in this repository)
*   `$ sls create --template aws-nodejs --path download-service`
    * set `provider.stage`
    * set `provider.region`
*   Delete the rest of the comments in the `serverless.yaml` -- they mostly go over things you don't need, frequently using **more complex/confusing syntax than you need**.
*   Your function will need:
    * The name of the bucket (passed as an environment variable)
    * Permissions to access that bucket (an `iamRoleStatement` allowing `s3:GetObject` on the bucket `arn`)
*   Set properties to be shared as custom properties & reference them elsewhere:

    ```yaml
    custom:
      snacksBucket: snack-bucket-123

    functions:
      triscuts:
        environment:
          BUCKET: ${self:custom.snacksBucket}
        iamRoleStatements:
          - Effect: Allow
            Resource: "arn:aws:s3:::${self:custom.snacksBucket}/*"
        # ...
    ```

*   The S3 SDK can return promises if you append `.promise()` to a call

    ```js
    s3.getObject({
      Key: 'file123.txt'
    })
    .promise()
    .then(file => {
      console.log(String(file.Body));
    })
    ```

# Step 13: Removing Assets: Thumbnails

Our thumbnail images are bundled with each "webapp" deployment and served by the webapp. This is less-than-ideal for several reasons:

1. There's no need to deploy multiple full copies of our thumbnails
2. This is "data" not "code" and therefor should be separate from our codebase
3. Node/Express is the ideal solution for serving static files

We'll move these assets to S3 which is better suited for serving static files. We'll also need to tell our books API server where thumbnails live (`THUMBNAIL_PATH`) and [add a `loaded` operation hook](https://loopback.io/doc/en/lb3/Operation-hooks.html#loaded) to our LoopBack Books model so it can modify responses to book lookups by prepending the thumbnail path (`book.thumbnail = url.resolve(THUMBNAIL_PATH, book.thumbnail`).

## Goals

1.  Add an operation hook to Books model to make it prepend a base path to thumbnails
    * Test it locally
    * Deploy to APIC
2.  Move static files to an S3 Bucket
3.  Expose S3 bucket publicly
    * Update Books API on APIC to point to S3
4.  See that it works
5.  Remove `assets/covers/` from monolith assets

## Hints

*   S3 *does not expose buckets as websites by default*, you  must enable it
*   You can test the LoopBack API server locally with `npm start`, just remember to pass it the appropriate environment variables (`BOOKS_DB` & `THUMBNAIL_PATH`)
*   `/covers/` is a reasonable default value if `process.env.THUMBNAIL_PATH` is not set
*   [Operation Hooks](https://loopback.io/doc/en/lb3/Operation-hooks.html#loaded)) work thus:
    ```js
    // common/models/books.js

    Books.observe('loaded', function(ctx, next){
      ctx.data; // book record to be modified
      next();   // call this when done
    })
    ```

*   If you prefer to keep everything going through your `*-monolith.now.sh` domain, try setting it up with an alias (instead of pointing directly to S3)
*   See `/misc/thumbnails-s3-policy.json` for a policy that will make your S3 bucket public.

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