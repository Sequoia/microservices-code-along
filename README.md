ℹ️ *See [INSTRUCTIONS.md](INSTRUCTIONS.md) for notes on using this repository.*

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