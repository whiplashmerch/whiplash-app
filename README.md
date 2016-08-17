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

###Authentication
In order to authenticate, make sure the following `ENV` vars are set:

```ruby
ENV["WHIPLASH_CLIENT_ID"]
ENV["WHIPLASH_CLIENT_SECRET"]
ENV["WHIPLASH_CLIENT_SCOPE"]
```
Once those are set, authentication is handled in app.  While authentication is
mostly baked into the calls, there is a method that allows for getting the app's
token from the main app: `Whiplash::App.token`.

### API URL
In order to set your api url, you can use the following environment URL:
```
ENV["WHIPLASH_API_URL"]
```
If it isn't set, then the API URL defaults to either `https://testing.whiplashmerch.com` or `https://www.whiplashmerch.com`.

###CRUD calls

The basic gist of these CRUD methods is that they will all follow the same pattern.  If you are performing a collection action, such as `create` or `find`, the pattern is this:
```
Whiplash::App.create(resource, params, headers)
```
For member actions, such as `show`, or `destroy` methods, the pattern is this:
```
Whiplash::App.find(resource, id, headers)
```
Finally, for `update` calls, it's a mixture of those:
```
Whiplash::App.update(resource, id, params_to_update, headers)
```

So, basic crud calls can be performed like so:
```ruby
Whiplash::App.find_all('orders', {}, { customer_id: 187 })
Whiplash::App.find('orders', 1)
Whiplash::App.create('orders', { key: "value", key2: "value" }, { customer_id: 187 } )
Whiplash::App.update('orders', 1, { key: "value"}, { customer_id: 187 } )
Whiplash::App.destroy('orders', 1, { customer_id: 187 } )
Whiplash::App.count('customers') #unlike other calls, which return Faraday responses, this call returns an integer.
```

Additionally, all of these methods are simply wrapper methods around simple `GET/POST/PUT/DELETE` wrappers on Faraday, so if you want to get more granular,
you can make a call like this:

```ruby
Whiplash.get('orders', {}, {})
```
Which will return all orders and roughly correspond to an index call. If you need to use `Whiplash::App` for nonRESTful calls, simply drop the full endpoint in as your first argument:

```ruby
Whiplash.get('orders/non_restful_action', {}, {})
```
###Signing and Verifying.
`whiplash-app` supports signing and verifying signatures like so:
```ruby
Whiplash::App.signature(request_body)
```
and verifications are done like so:
```ruby
Whiplash::App.verified?(request)
```  

###Caching
`whiplash-app` is Cache agnostic, relying on the `moneta` gem to provide that
interface.  However, if you intend to specify `REDIS` as your key-value store of
choice, it's dead simple.  Simply declare the following variables:
```
ENV["REDIS_HOST"]
ENV["REDIS_PORT"]
ENV["REDIS_PASSWORD"]
ENV["REDIS_NAMESPACE"]
```
If those are provided, `moneta` will use your redis connection and will namespace your cache storage under the redis namespace.  By default, if you do not declare a `REDIS_NAMESPACE` value, the app will default to the `WHIPLASH_CLIENT_ID`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/whiplash-app.
