# CzechPostB2bClient
Accessing B2B API of Czech Post for bulk processing of packages ("B2B - WS PodáníOnline").

There are these supported operations on API:
- *sendParcels* - stores data of parcels for async processing [HTTP POST - async response]
- *getResultParcels* - return results of such processing [HTTP GET - sync response]
- *getStats* - returns statistics of parcels sent in time period [HTTP GET - sync response]
- *getParcelState* - returns all known states for listed parcels [HTTP GET - sync response]
- *getParcelsPrinting* - returns PDF with address labels/stickers for listed parcels [HTTP GET - sync response]

## Common usage/user story ##
1) Collect parcels data in Your app
2) Call *sendParcel*, which will store required parcels data and transmit them to Your local post office.
3) Print address stickers (*getParcelsPrinting*) and put them on parcels.
4) Deliver parcels to Your local post office.
5) Periodically check status of delivering by calling *getParcelState*.
6) Improve your guesstimation of delivery time by working with historical data collected through *getStats*.




Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/czech_post_b2b_client`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'czech_post_b2b_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install czech_post_b2b_client

## Usage

### Configuration ###
You have to add Your `contract_id` and path to certificate to configuration
```
CzechPostB2bClient.configure do |config|
  config.contract_id = '123456'
  config.path_from_root_to_certificate = './post_cert.crt'
  config.language = :cs
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/czech_post_b2b_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CzechPostB2bClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/czech_post_b2b_client/blob/master/CODE_OF_CONDUCT.md).
