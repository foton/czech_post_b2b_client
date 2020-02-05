# CzechPostB2bClient
Accessing B2B API of Czech Post for bulk processing of parcels ("B2B - WS PodáníOnline").

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


## Installation
### Registration at Czech Post
Get  "komerční certifikát PostSignum" ( 1month testing version can be obtained at http://www.postsignum.cz/testovaci_certifikat.html).
https://b2b.postaonline.cz supports TLS 1.2, 1.1. 1.0

### Gem installation

Add this line to your application's Gemfile:

```ruby
gem 'czech_post_b2b_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install czech_post_b2b_client

### Setting up gem
   Set up your `contract_id`, `customer_id` (both from CP signed contract), `certificate_path` and `certificate_password` in configuration:
   ```
    CzechPostB2bClient.configure do |config|
      config.contract_id = 'contract_id' # from CP signed contract
      config.customer_id = 'customer_id' # from CP signed contract
      config.certificate_path = 'full_path/to/your/postsignum_certificate.pem'
      config.private_key_path = 'full_path/to/your/postsignum_certificate_private.key'
      config.private_key_password = 'your_password'
      config.sending_post_office_code = 12_345 # PSC of post office where parcels will be physically delivered and submitted
    end
   ```
   Because PostSignum Certificate Authority is not trusted by default, correct certificate chain is in `certs/` folder. If You have problem with them, create and issue. Maybe they are outdated now.

## Usage
  You have to know which parcel type (according to CP) you sending! Eg. 'BA' or 'RR'.

  1) Pack your parcel(s)
  2) Call `ParcelsSender.call(sending_data: sender_data, parcels: parcels)`, this will return expected time to ask for results and `transmission_id`.

     For now, `parcels` is array of complicated hashes; each parcel must have `parcel_id` key (your ID of parcel).
  3) When such expected time pass, ask for results by calling `ParcelsSendProcessUpdater.call(transmission_id: transmission_id)`.

     You can get error `Processing is not yet finished` or hash based on `parcel_id` keys.
     Eg. :
     ```
     { 'parcel_id1' => {parcel_code: 'RA12345687', status_code: '1', state_text: 'OK' }, }
     ```
     `parcel_code` is CzechPost ID of parcel and is used in following calls.
  4) Print address sheets of parcels(s) by calling `AddressSheetsGenerator.call(parcel_codes: parcel_codes, options: options )`.
     Eg. :
     ```
     parcel_codes = %w[RA123456789 RR123456789F RR123456789G] # beware of parcel_id!
     options = {
          customer_id: configuration.customer_id, # required
          contract_number: configuration.contract_id, # not required
          template_id: 24, # 'obalka 3 - B4'   : not required !? , see `lib/czech_post_b2b_client/printing_templates.rb` for templates
          margin_in_mm: { top: 5, left: 3 } # required
        }
     ```

  5) Repeat steps 1-4 until You decide to deliver packages to post office.

  6) Close your parcels submission by `ParcelsSubmissionCloser.call(sending_data: sender_data)`.
  7) _They will await You at post office with warm welcome (hopefully). Parcels which are not delivered within 60 days are removed from CzechPost systems for free :-)_
  8) You can check current status of delivering by `DeliveringInspector.call(parcel_codes: parcel_codes)`, which will return hash based on `parcel_code` keys.
     Eg. :
     ```
     { 'RA12345687' => { current_state: { id: '91',
                                           date: Date.parse('2015-09-04'),
                                           text: 'Dodání zásilky.',
                                           post_code: '25756',
                                           post_name: 'Neveklov'},
                         deposited_until: Date.new(2015, 9, 2),
                         deposited_for_days: 15,
                         all_states: [
                           { id: '21', date: Date.parse('2015-09-02'), text: 'Podání zásilky.', post_code: '26701', post_name: 'Králův Dvůr u Berouna' },
                           { id: '-F', date: Date.parse('2015-09-03'), text: 'Vstup zásilky na SPU.', post_code: '22200', post_name: 'SPU Praha 022' },
                           { id: '-I', date: Date.parse('2015-09-03'), text: 'Výstup zásilky z SPU.', post_code: '22200', post_name: 'SPU Praha 022' },
                           { id: '-B', date: Date.parse('2015-09-03'), text: 'Přeprava zásilky k dodací poště.', post_code: nil, post_name: nil },
                           { id: '51', date: Date.parse('2015-09-04'), text: 'Příprava zásilky k doručení.', post_code: '25607', post_name: 'Depo Benešov 70' },
                           { id: '53', date: Date.parse('2015-09-04'), text: 'Doručování zásilky.', post_code: '25756', post_name: 'Neveklov' },
                           { id: '91', date: Date.parse('2015-09-04'), text: 'Dodání zásilky.', post_code: '25756', post_name: 'Neveklov' }
                         ]}
     ```
  9) And You can always ask for statistics! Use `TimePeriodStatisticator.call(from_date: date_from, to_date: date_to)`.

  ### Example usage

  See `test/integration_test.rb` for almost production usage. HTTP calls to B2B services are blocked and responses from them are stubbed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/czech_post_b2b_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CzechPostB2bClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/czech_post_b2b_client/blob/master/CODE_OF_CONDUCT.md).
