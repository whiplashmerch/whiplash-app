# whiplash-app  

The whiplash-app gem allows your Whiplash application to access the Whiplash
API and perform authentication, signatures and signature verification, and basic
CRUD functions against the api.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'whiplash-app'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install whiplash-app

## Usage

**NOTE: 0.4.0 introduces a breaking change and is NOT backward compatible with previous versions.**

To upgrade from < 0.4.0, you need to make two small changes:
1. `Whiplash::App` must now be instantiated.
2. Tokens are **not** automatically refreshed

Before:
```ruby
api = Whiplash::App
```

After:
```ruby
api = Whiplash::App.new
api.refresh_token! # Since you don't have one yet
api.token # Confirm you've got a token
. . .
api.refresh_token! if api.token_expired?
```

### Authentication
In order to authenticate, make sure the following `ENV` vars are set:

```ruby
ENV["WHIPLASH_CLIENT_ID"]
ENV["WHIPLASH_CLIENT_SECRET"]
ENV["WHIPLASH_CLIENT_SCOPE"]
```

Once those are set, authentication is handled in app.

### Oauth Client Credentials
You can authenticate using Oauth Client Credentials (i.e. auth an entire app).
You probably want this for apps that work offline, _on behalf_ of users or customers, or that don't work at the user/customer-level at all.

```ruby
api = Whiplash::App.new
api.refresh_token! # Since you don't have one yet
api.token # Confirm you've got a token
```

### Oauth Authorization Code
You can also authenticate using Oauth Authorization Code (i.e. auth an individual user). This is most common for user-facing app's with a front end.

```ruby
# Authenticate using Devise Omniauthenticateable strategy; you'll get oauth creds back as a hash
api = Whiplash::App.new(oauth_credentials_hash)
api.token # Confirm you've got a token
```

### API URL
In order to set your api url, you can use the following environment URL:
```
ENV["WHIPLASH_API_URL"]
```
If it isn't set, then the API URL defaults to either `https://testing.whiplashmerch.com` (test or dev environment) or `https://www.whiplashmerch.com` (prod environment).

### Sending Customer ID and Shop ID headers
You can send the headers in `headers` array, like `{customer_id: 123, shop_id: 111}`.
Alternatively, you can set them on instantiation like `Whiplash::App.new(token, {customer_id: 123, shop_id: 111})`.

### Rails AR type calls

In order to make the use of the gem seem more "AR-ish", we've added AR oriented methods that can be used for basic object creation/deletion/updating/viewing. The basic gist of these AR style CRUD methods is that they will all follow the same pattern.  If you are performing a collection action, such as `create` or `find`, the pattern is this:

```ruby
api.create(resource, params, headers)
```

For member actions, such as `show`, or `destroy` methods, the pattern is this:

```ruby
api.find(resource, id, headers)
api.destroy(resource, id, headers)
```

Finally, for `update` calls, it's a mixture of those:

```ruby
api.update(resource, id, params_to_update, headers)
```

So, basic AR style calls can be performed like so:

```ruby
api.find_all('orders', {}, { customer_id: 187 })
api.find('orders', 1)
api.create('orders', { key: "value", key2: "value" }, { customer_id: 187 } )
api.update('orders', 1, { key: "value"}, { customer_id: 187 } )
api.destroy('orders', 1, { customer_id: 187 } )
api.count('customers')
```

### CRUD Wrapper methods
In reality, all of these methods are simply wrapper methods around simple `GET/POST/PUT/DELETE` wrappers on Faraday, so if you want to get more granular,you can also make calls that simply reference the lower level REST verb:

```ruby
api.get('orders')
```
Which will return all orders and roughly correspond to an index call. If you need to use `Whiplash::App` for nonRESTful calls, simply drop the full endpoint in as your first argument:

```ruby
api.get('orders/non_restful_action', {}, {})
```
`POST`, `PUT`, and `DELETE` calls can be performed in much the same way:
```ruby
api.post(endpoint, params, headers) # POST request to the specified endpoint passing the payload in params
api.put(endpoint, params, headers) # PUT request to the specified endpoint passing the payload in params
api.delete(endpoint, params, headers) # DELETE request to the specified endpoint.  Params would probably just be an id.
```

### Signing and Verifying.
`whiplash-app` supports signing and verifying signatures like so:
```ruby
Whiplash::App.signature(request_body)
```
and verifications are done like so:
```ruby
Whiplash::App.verified?(request)
```  

### Caching
`whiplash-app` is Cache agnostic, relying on the `moneta` gem to provide a local store, if needed.  
However, if you intend to specify `REDIS` as your key-value store of choice, it's dead simple.  Simply declare the following variables:
```
ENV["REDIS_HOST"]
ENV["REDIS_PORT"]
ENV["REDIS_PASSWORD"]
ENV["REDIS_NAMESPACE"]
```
If those are provided, `moneta` will use your redis connection and will namespace your cache storage under the redis namespace.  By default, if you do not declare a `REDIS_NAMESPACE` value, the app will default to the `WHIPLASH_CLIENT_ID`.

**For user-facing apps, best practice is to store the `oauth_credentials_hash` in a session variable.**

### Gotchas
Due to the way Faraday handles params, this would not, as expected, route to `orders#show` in the Whiplash App, but would instead route to `orders#index`, so it wouldn't return the expected singular order with an ID of 1, but all orders for that customer.
```ruby
api.get('orders', {id: 1}, {customer_id: 187})  
```
Instead, you'd want to do:
```ruby
api.get('orders/1', {}, {customer_id: 187})  
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/whiplash-app.
