# whiplash-app  

The whiplash-app gem allows your Whiplash application to access the Whiplash
API and perform authentication, signatures and signature verification, and basic
CRUD functions against the api.

For apps that provide a UI, it also provides built in authentication and several helper methods.

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

There are two basic uses for this gem:
1. Authenticating users for apps _with a UI_ (i.e. Notifications, Troubleshoot, etc)
2. Providing offline access to applications that perform tasks (i.e Tasks, Old Integrations, etc)

It's not uncommon for an application to do _both_ of the above (i.e. Notifications, Payments, etc)

### Authentication for offline access (Oauth Client Credentials flow)
In order to authenticate, make sure the following `ENV` vars are set:

```ruby
ENV['WHIPLASH_API_URL']
ENV['WHIPLASH_CLIENT_ID']
ENV['WHIPLASH_CLIENT_SCOPE']
ENV['WHIPLASH_CLIENT_SECRET']
```

Once those are set, you can generate and use an access token like so:

```ruby
token = Whiplash::App.client_credentials_token
api = Whiplash::App.new(token)
customers = api.get!('customers')
```

### Authentication for online access
In order to use the API, you only need to set the following:

```ruby
ENV['WHIPLASH_API_URL']
```

As long as all of your apps are on the same subdomain, they will share auth cookies:

```json
{
    "oauth_token": "XXXXXXX",
    "user": {"id":151,"email":"mark@getwhiplash.com","role":"admin","locale":"en","first_name":"Mark","last_name":"Dickson","partner_id":null, "customer_ids":[1, 2, 3]},
    "customer": {"id": 123, "name": "BooYaa"},
    "warehouse": {"id": 1, "name": "Ann Arbor"}
}
```

You get a variety of helper methods for free:

`init_whiplash_api` - This instantiates `@whiplash_api` which can be used to make requests, out of the box
`current_user` - This is a **hash** with the above fields; you typically shouldn't need much more user info than this'
`current_customer` - This is a **hash** with the above fields; you typically shouldn't need much more user info than this
`current_warehouse` - This is a **hash** with the above fields; you typically shouldn't need much more user info than this
`require_user` - Typically you'd use this in a `before_action`. You almost always want this in `ApplicationController`.
`set_locale!` - Sets the locale based on the value in the user hash
`set_current_user_cookie!` - Updates the current user cookie with fresh data from the api. You typically won't need this, unless your app updates fields like `locale`.
`set_current_customer_cookie!` - Updates the current customer cookie with fresh data from the api; typically used after you've changed customer
`set_current_warehouse_cookie!` - Updates the current customer cookie with fresh data from the api; typically used after you've changed warehouse
`unset_current_customer_cookie!` - Deletes the current customer cookie, with appropriate domain settings
`unset_current_warehouse_cookie!` - Deletes the current warehouse cookie, with appropriate domain settings
`core_url` - Shorthand for `ENV['WHIPLASH_API_URL']`
`core_url_for` - Link back to Core like `core_url_for('login')`


### Sending Customer ID and Shop ID headers
You can send the headers in `headers` array, like `{customer_id: 123, shop_id: 111}`.
Alternatively, you can set them on instantiation like `Whiplash::App.new(token, {customer_id: 123, shop_id: 111})`


### CRUD Wrapper methods

```ruby
api.get('orders')
```

```
`POST`, `PUT`, and `DELETE` calls can be performed in much the same way:
```ruby
api.post(endpoint, params, headers) # POST request to the specified endpoint passing the payload in params
api.put(endpoint, params, headers) # PUT request to the specified endpoint passing the payload in params
api.delete(endpoint, params, headers) # DELETE request to the specified endpoint.  Params would probably just be an id.
```

### Bang methods

In typical Rails/Ruby fashion, `!` methods `raise`. Typically, you'll want to set some global `rescue`s and use the `!` version of crud requests:

```ruby
rescue_from WhiplashApiError, with: :handle_whiplash_api_error

def handle_whiplash_api_error(exception)
    # Any special exceptions we want to handle directly
    case exception.class.to_s
    when 'WhiplashApiError::Unauthorized'
      return redirect_to core_url_for('logout')
    end
    
    @status_code = WhiplashApiError.codes&.invert&.dig(exception&.class)
    @error = exception.message
    respond_to do |format|
      format.html {
        flash[:error] = @error
        redirect_back(fallback_location: root_path)
      }
      format.json {
        render json: exception, status: @status_code
      }
      format.js {
        render template: 'resources/exception'
      }
    end
end
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/whiplash-app.
