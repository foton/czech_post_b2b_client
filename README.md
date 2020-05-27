# CzechPostB2bClient
Accessing B2B API of Czech Post for bulk processing of parcels ("B2B - WS PodáníOnline").

There are these supported operations of API:
- *parcelServiceSync* - stores data of one parcel and return package_code and optional PDF adress sheet [HTTP POST - sync response]
                        Seems to me, that there are is no place extensive Cash On Delivery data, just `amount` and `currency`
- *sendParcels* - stores data of parcels for async processing [HTTP POST - async response]
- *getResultParcels* - return results of such processing [HTTP GET - sync response]
- *getStats* - returns statistics of parcels sent in time period [HTTP GET - sync response]
- *getParcelState* - returns all known states for listed parcels [HTTP GET - sync response]
- *getParcelsPrinting* - returns PDF with address labels/stickers for listed parcels [HTTP GET - sync response]


## Installation
### 1) Registration at Czech Post (CP)
The longterm and hardest part.
- Connect Czech Post representative and make a contract with them.
- Ask them for ALL documentation!(I have to ask 3 times to collect enough of it). They like to put files into DOCX file, so click on file icons!
- You have to obtain "komerční certifikát PostSignum".

Instructions (in czech) are in [`documents/Postup_pro_zavedení_API_služeb_České_pošty.docx`](./documents/Postup_pro_zavedení_API_služeb_České_pošty.docx)

### 2) Preparations on PodaniOnline app
1) Sign in to [PostaOnline](https://www.postaonline.cz/rap/prihlaseni)
2) Go to ["Podání Online"](https://www.postaonline.cz/klientskazona?p_p_id=clientzone_WAR_clientZoneportlet&p_p_lifecycle=0&_clientzone_WAR_clientZoneportlet_action=showPol&_clientzone_WAR_clientZoneportlet_implicitModel=true)
3) When You are in, select tab **Nastavení** and menu **Podací místa**
4) Add _Podací místo_ and write down it's ID (will be used in `sending_post_office_location_number`)
5) Switch tab to **Zásilky** and go to menu **Zásilky => Přednastavení údajů**
6) Write down value(s) in _Výběr technologického čísla_ (it will be used as `customer_id`).


### 3) Gem installation
Add this line to your application's Gemfile:

```ruby
gem 'czech_post_b2b_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install czech_post_b2b_client

### 4) Setting up gem
   Set up your `contract_id`, `customer_id` (both from CP signed contract), `certificate_path`, `private_key_path` and `private_key_password` in configuration:
   ```
    CzechPostB2bClient.configure do |config|
      config.contract_id = 'contract_id'
      config.customer_id = 'customer_id'
      config.certificate_path = 'full_path/to/your/postsignum_certificate.pem'
      config.private_key_path = 'full_path/to/your/postsignum_private.key'
      config.private_key_password = 'your_password or nil'

      # this actually do not work, I have to use `sending_post_office_location_number`. But it is REQUIRED!
      config.sending_post_office_code = 12_345 # PSC of post office where parcels will be physically delivered and submitted

      # and You can override defaults
      # config.sending_post_office_location_number => 1
      # config.namespaces #XML namespaces
      # config.language => :cs # other languages are not supported now
      # config.logger => ::Rails.logger or ::Logger.new(STDOUT),
      # config.b2b_api_base_uri => 'https://b2b.postaonline.cz/services/POLService/v1'
    end
   ```

   - `contract_id` is _"ID CČK"_ (can be found in contract; eg.: _"2511327004"_)
   - `customer_id` is _"Technologické číslo"_ (can be found in contract; eg.: _"U123"_ or _"L03022"_; also is visible at [PodaníOnline](https://www.postaonline.cz/podanionline/PrednastaveniUdajuZasilky.action)

   Because PostSignum Certificate Authority is not trusted by default, correct certificate chain is in `certs/` folder. If You have problem with them, create a issue here. Maybe they are outdated now.

## Usage
  **You have to know which parcel type (according to CP) you sending!** Eg. 'BA' or 'RR'. See [`documents/parcel_types.md`](./documents/parcel_types.md).

  **And what services You will use for each parcel**, see [`documents/services_list.md`](./documents/services_list.md) and [`documents/parcels_type_and_services_restrictions.md`](./documents/parcels_type_and_services_restrictions.md).

  Hashes used is service calls bellow:
  ```
    short_sender_data = { address: {
                            company_name: 'Oriflame',
                            addition_to_name: 'perfume', # optional
                            street: 'V olšinách',
                            house_number: '16',
                            city_part: 'Strašnice',
                            city: 'Praha',
                            post_code: 10_000,
                          },
                          mobile_phone: '+420777888999',
                          email: 'rehor.jan@cpost.cz' }
    sending_data = { contract_id: configuration.contract_id,
                     parcels_sending_date: Date.today,
                     sending_post_office_location_number: 1,
                     sender: short_sender_data,
                     cash_on_delivery: {
                       address: short_sender_data[:address]
                       bank_account: '123456-1234567890/1234'
                     } }

    short_addressee_data = { address: {
                              first_name: 'Petr',
                              last_name: 'Foton',
                              street: 'Fischerova',
                              house_number: '686',
                              sequence_number: '32',
                              city_part: 'Nové Sady',
                              city: 'Olomouc',
                              post_code: 77_900
                            },
      email: 'foton@github.com',
      mobile_phone: '+420777888999' }

    parcels = [
      {
        addressee: short_addressee_data,
        params: { parcel_id: 'package_1of2',
                  parcel_code_prefix: 'BA',
                  weight_in_kg: 1.0,
                  parcel_order: 1,
                  parcels_count: 2 },
        services: [70, 7, 'S']
      },
      {
        addressee: short_addressee_data,
        params: { parcel_id: 'package_2of2',
                  parcel_code_prefix: 'BA',
                  weight_in_kg: 1.6,
                  parcel_order: 2,
                  parcels_count: 2 },
        services: [70,'S']
      },
      {
        addressee: short_addressee_data,
        params: { parcel_id: 'package_3',
                  parcel_code_prefix: 'BA',
                  weight_in_kg: 1.9 },
        services: [7,'M']
      }
    ]
```


  1) Pack your parcel(s)

  2) Call `ParcelsAsyncSender`, this will store in `result` `transmission_id` and expected time to ask for results.
      ```
        psender = CzechPostB2bClient::Services::ParcelsAsyncSender.call(sending_data: sending_data, parcels: parcels)

        if psender.success?
          result = psender.result
          processing_end_time_utc = (result.processing_end_expected_at - (60 *60)).utc # API returns time in CET but marked as UTC
          transaction_id = result.transaction_id
        else
          puts psender.errors.full_messages
        end
      ```
     For now, `parcels` is array of complicated hashes; each parcel must have `parcel_id` key (your ID of parcel).

  3) When such expected time pass, ask for results by calling `ParcelsSendProcessUpdater`.

     You can get error `Processing is not yet finished` or hash based on `parcel_id` keys.
     Eg. :
     ```
        pudater = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transmission_id: transmission_id)

        if pupdater.success?
          update_my_parcels_with(pupdater.result) # => { 'parcel_1of2' => { parcel_code: 'BA12354678', states: [{ code: 1, text: 'OK' }]},
                                                  #      'parcel_2of2' => { parcel_code: 'BA12354679', states: [{ code: 1, text: 'OK' }]},
                                                  #      'parcel_3' => { parcel_code: 'BA12354680', states: [{ code: 1, text: 'OK' }]}
        else
          puts psender.errors.full_messages # => "response_state: ResponseCode[19 BATCH_INVALID] V dávce se vyskytují chybné záznamy"
                                            #    "parcels: Parcel[parcel_2of2] => ResponseCode[104 INVALID_WEIGHT] Hmotnost mimo povolený rozsah"
                                            #    "parcels: Parcel[parcel_2of2] => ResponseCode[261 MISSING_SIZE_CATEGORY] Neuvedena rozměrová kategorie zásilky"
                                            #    "parcels: Parcel[parcel_3] => ResponseCode[310 INVALID_PREFIX] Neplatný typ zásilky"
        end
     ```
     `parcel_code` is CzechPost ID of parcel and is used in following calls.

  4) Print address sheets of parcels(s) by calling `AddressSheetsGenerator`.
     See [template_classes](./lib/czech_post_b2b_client/printing_templates.rb) for available templates.
     Eg. :
     ```
     parcel_codes = %w[RA123456789 RR123456789F RR123456789G] # beware of parcel_id!
     options = {
          customer_id: configuration.customer_id, # required
          contract_number: configuration.contract_id, # not required
          template_id: 24, # 'obalka 3 - B4'  #
          margin_in_mm: { top: 5, left: 3 } # required
        }

      adrprinter = CzechPostB2bClient::Services::AddressSheetsGenerator.call(parcel_codes: parcel_codes, options: options )

      if adrprinter.success?
        File.write("adrsheet.pdf", adrprinter.result.pdf_content)
      else
        puts(adrprinter.errors.full_messages)
      end
     ```

  5) Repeat steps 1-4 until You decide to deliver packages to post office.

  6) Close your parcels submission with call `ParcelsSubmissionCloser.call(sending_data: sender_data)`.

  7) _They will await You at post office with warm welcome (hopefully). Parcels which are not delivered within 60 days are removed from CzechPost systems for free :-)_

  8) You can check current status of delivering with `DeliveringInspector`, which will return hash based on `parcel_code` keys.
     Eg. :
     ```
      delivery_boy = CzechPostB2bClient::Services::DeliveringInspector.call(parcel_codes: parcel_codes)

      if delivery_boy.success?
        update_my_parcels_delivery_status_with(delivery_boy.result)
        # result is like:
        # { 'RA12345687' => { current_state: { id: '91',
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
                              ]},
            'BA56487125' => {...}
          }
      else
        puts(delivery_boy.errors.full_messages)
      end
      ```

  9) And You can always ask for statistics!
      ```
      tps = CzechPostB2bClient::Services::TimePeriodStatisticator.call(from_date: Date.today - 5, to_date: Date.today)
      if tps.success?
        result = tps.result
        result.requests.total # => 26,
        result.requests.with_errors # => 16
        result.requests.successful # => 10
        result.imported_parcels # => 3
      else
        puts(tps.errors.full_messages)
      end
      ```

### Example usage

  See `test/integration_test.rb` for almost production usage. HTTP calls to B2B services are blocked and responses from them are stubbed.

  You can quickly check you setup by altering config and run `ruby try_api_calls.rb` see [`try_api_calls.rb`](./examples/try_api_calls.rb).

## Troubleshooting

  1) Read all stuff in [`./documents`](./documents/) and [Yard docs](./doc/index.html), maybe it helps.
  2) If You get "handshake protocol failed" You do not have correct setup for certificates. If You get any xml response (see logger in debug mode) certificates are ok.
     You can always try `TimePeriodStatisticator` for that check, it do not need any "before" actions.
  3) Error `UNAUTHORIZED_ROLE_ACCESS` means wrong `customer_id` or You are not yet registered in "PodáníOnline"
  4) Error `11: INVALID_LOCATION` was occuring when only `sending_post_office_code` was used. Try to use `sending_post_office_location_number`.
  5) And last tip `261 MISSING_SIZE_CATEGORY` -> add correct "size service" to services (eg: 'S', 'M')
  6) Compare resulting request XML with examples in `test/request_builders`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `lib/czech_post_b2b_client/version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/czech_post_b2b_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CzechPostB2bClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/czech_post_b2b_client/blob/master/CODE_OF_CONDUCT.md).
