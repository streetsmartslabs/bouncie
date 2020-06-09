# Bouncie

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bouncie'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bouncie

## Usage

Instantiate a client by passing an `options` hash with at least your app's `api_key` and your user account's `authorization_code'.
```ruby
client = Bouncie::Client.new(api_key: [MY_KEY], authorization_code: [MY_CODE])

vehicles = client.vehicles

trips = client.trips(imei: [MY_VEHICLE_IMEI])
```

API documentation is available at [docs.bouncie.dev](https://docs.bouncie.dev).

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/streetsmartslabs/bouncie.
