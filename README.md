# Decidim::Apiext

A [Decidim](https://github.com/decidim/decidim) module to extend the the GraphQL
API in Decidim to provide create, update and delete capabilities for some of the
records available in Decidim. This module also provides the management of the
API credentials at the `/system` panel and implements JWT token based
authentication for the API credentials.

The following API capabilities are added:

- Management of API credentials at the `/system` panel
- Sign in with the API credentials using a custom `/api/sign_in` endpoint
- Sign out from the API (i.e. revoke the JWT token) using a custom
  `/api/sign_out` endpoint
- Authenticating the requests using the issued JWT token within the
  `Authorization` header
- Proposals
  * Answer proposal
- Budgets
  * Create budget
  * Update budget
  * Delete budget
  * Create project
  * Update project
  * Delete project
- Accountability
  * Create result
  * Update result
  * Delete result
  * Create timeline entry
  * Update timeline entry
  * Delete timeline entry
- Files/attachments (through the [API files module](https://github.com/mainio/decidim-module-apifiles))
  * Upload a file
  * Delete a file
  * Attach the file to a record (e.g. a budgets project)
  * Create attachment
  * Update attachment
  * Delete attachment
  * Create attachment collection
  * Update attachment collection
  * Delete attachment collection

In addition, the API user is able to perform any other actions through the API
that would be normally available for normal users, such as sending new comments.

The authentication is based on
[Devise::JWT](https://github.com/waiting-for-dev/devise-jwt).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-apiext", github: "City-of-Turku/decidim-module-apiext", branch: "main"
```

And then execute:

```bash
$ bundle
$ bundle exec rails decidim_apiext:install:migrations
$ bundle exec rails decidim_apifiles:install:migrations
$ bundle exec rails db:migrate
```

Then, configure a secret key by adding the following to your application's
`config/secrets.yml`:

```yaml
development:
  <<: *default
  # ...
  secret_key_jwt: generate_a_key_here

test:
  <<: *default
  # ...
  secret_key_jwt: generate_a_key_here

# Do not keep production secrets in the repository,
# instead read values from the environment.
production:
  <<: *default
  # ...
  secret_key_jwt: <%= ENV["SECRET_KEY_JWT"] %>
```

You can generate the key from the console by running:

```bash
$ bundle exec rails secret
abcdef123456... <-- (This printed line is the secret)
```

This key is used to encrypt and decrypt the API tokens. You will see an
exception at the application startup in case this is not defined because it is
essential for the JWT encryption and decryption to work correctly. Otherwise the
token validation and checking simply would not work correctly.

## Usage

After installing this module, you should go through all these steps to ensure
that the module is installed correctly. It will make it easier to troubleshoot
any problems you may encounter. It is also suggested to do these steps once for
each API credentials

1. Login to the `/system` panel of the Decidim instance and browse to the "API
  credentials" section
2. Create new API credentials using the "New API user" link at the top right
   corner. Copy the API key and secret to your environment configuration. The
   following steps will assist testing the credentials work correctly.
  * Select the organization for which this API user belongs to. These
    credentials are limited only to that organization.
  * Give a name for the API user. This will be the name of the user that appears
    publicly on the platform, e.g. with the comments created by this user.
3. Login to the API
```
curl --include --location --request POST 'http://localhost:3000/api/sign_in' \
  --form 'api_user[key]="ABcdeFGH123IjKL45Mn6opqRSTUVWxy6"' \
  --form 'api_user[secret]="ABcdeFGH123IjKL45Mn6opqRSTUVWxy6"'
```
4. Save [jwt](https://jwt.io/introduction) web token from response
  * You should see the header either from the response headers' (`Authorization`
    header) or from the JSON payload (`jwt_token` field).
5. Include token to further requests (note that the token needs to be prefixed
   with the schema, i.e. `Bearer`)
```
curl --location --request POST 'http://localhost:3000/api' \
  --header 'Authorization: Bearer replace_this_with_token' \
  --header 'Content-Type: application/json' \
  --data-raw '{"query":"{ session { user { id nickname } } }","variables":{}}'
```
6. Finally, log out from the API
```
curl --location --request DELETE 'http://localhost:3000/api/sign_out' \
  --header 'Authorization: Bearer replace_this_with_token'
```
7. In order to validate a successful logout, you can try any API request with
   this token and you should get a HTTP 302 redirect response if the API
   authentication is forced (default). If the API authentication is not forced,
   you can retry the session request and it should return empty details after
   the user is logged out.

### Troubleshoot

In case you run into problems like getting `{"data":{"session":null}}` with the
example queries presented below, go through these steps:

1. Make sure you are not logged in already
2. In production / staging check that request URL has https protocol (not http)!
3. Make sure that request has `Content-Type: application/json` and
   `Content-Length`
4. If you are using [Postman](https://www.postman.com/) or other such API
   development tools, create a clean new request
5. Make sure that secrets (`config/secrets.yml`) are defined as instructed in
   this documentation (and `SECRET_KEY_JWT` environment variable has been set
   for production / staging):
```yaml
# config/secrets.yml
production:
  <<: *default
  # ...
  secret_key_jwt: <%= ENV["SECRET_KEY_JWT"] %>
```

## Configuration

By default, this module forces any requests to the API to be authenticated. In
other words, the API is inaccessible unless the user is authenticated. In case
you want to allow the public read API for anyone, you can change the following
configuration in your initializer:

```ruby
# config/initializers/decidim.rb
Decidim::Apiext.configure do |config|
  config.force_api_authentication = true
end
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

### Testing

To run the tests run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
