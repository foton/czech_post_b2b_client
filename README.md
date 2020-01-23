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


## Instalation
### Registration at Czech Post
Get  "komerční certifikát PostSignum" ( 1month testing version can be obtained at http://www.postsignum.cz/testovaci_certifikat.html).
https://b2b.postaonline.cz supports TLS 1.2, 1.1. 1.0

### Setting up gem
   Set up your `contract_id`, `customer_id` (both from CP signed contract), `certificate_path` and `certificate_password` in configuration:
   ```
    CzechPostB2bClient.configure do |config|
      config.contract_id = 'contract_id' # from CP signed contract
      config.customer_id = 'customer_id' # from CP signed contract
      config.certificate_path = 'full_path/to/your/postsignum_certificate'
      config.contract_id = 'certificate_password'
      config.sending_post_office_code = 12_345 # PSC of post office where parcels will be physically delivered and submitted
    end
   ```
   Because PostSignum Certificate Authority is not trusted by default, correct certificate chain is in `certs/` folder. If You have problem with them, create and issue. Maybe they are outdated now.

## Usage
  You have to know which parcel type (according to CP) you sending.

  1) Pack your parcel(s)
  2) Call `ParcelsSender.call(sender_data, parcels)` , this will return expected time to ask for results and `transmission_id`.
  3) When such time passed ask for results by calling `ParcelsSendProcessUpdater.call(transmission_id)`. You can get error `Processing is not yet finished` or parcels have assigned `code` and `sending_state` (matching parcels by `id`)
  4) Print address sheets of parcels(s) by calling `AddressSheetsGenerator.call(parcels)`

  5) Repeat steps 1-4 untill You deside to deliver packages to post office.

  6) Close your parcels submission by `ParcelsSubmissionCloser.call`.
  7) They will await You at post office with warm welcome (hopefully).
  8) You can check current status of delivering by `DeliveringInspector.call(parcels)`, which will update `parcel.current_state`, `parcel.last_state_change` and `parcel.state_changes`.
  9) And You can always ask for statistics! Use `PeriodStatisticator.call(from: date_from, to: date_to)`.

  ### Example usage
  ```
  sender_adress =  CzechPostB2bClient::Address(first_name:, last_name:)
  sender_data =  CzechPostB2bClient::SenderData(address: sender_adress)
  ...
  ``






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
