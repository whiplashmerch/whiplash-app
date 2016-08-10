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

###CRUD calls
Basic crud calls can be performed like so:
```ruby
Whiplash::App.find_all('orders', { customer_id: 187 })
Whiplash::App.find('orders', 1)
Whiplash::App.create('orders', params: {})
Whiplash::App.update('orders', 1, params: {})
Whiplash::App.destroy('orders', 1)
```
Additionally, all of these methods are simply wrapper methods around simple `GET/POST/PUT/DELETE` wrappers on Faraday, so if you want to get more granular,
you can make a call like this:
```ruby
Whiplash.get('orders', {}, {})
```
Which will return all orders and roughly correspond to an index call.

###Signing and Verifying.
`whiplash-app` supports signing and verifying signatures like so:
```ruby
Whiplash::App.signature(request_body)
```
and verifications are done like so:
```ruby
Whiplash::App.verified?(request)
```  

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/whiplash-app.
