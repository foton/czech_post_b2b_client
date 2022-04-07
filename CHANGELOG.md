# Changelog

All changes to the gem are documented here.

## [1.3.0] - 2022-04-07
 - checked currently available  Print Templates codes
 - enhanced address sheet printing with ability to print ZPL sheets (templates 200, 201 and 202).
   Result of `AddressSheetGenerator` now have `pdf_content` and `zpl_content`.
 - found new(?) API from Czech Post , see `documents/B2B-ZSKService-1.4.0.yaml` and https://www.ceskaposta.cz/napi/b2b.

## [1.2.8] - 2022-03-22
  - added new response codes

## [1.2.6] - 2020-10-27

 - fixed passing all errors from `parcelsServiceSync` response.

## [1.2.5] - 2020-10-06

 - `errorDescription` from `B2BError` response is now merged into error message.

## [1.2.4] - 2020-10-06

 - Added `configuration.log_messages_at_least_as` option, to be able debug client behaviour when app log level is higher (eg. production)

## [1.2.3] - 2020-08-21

 - Corrected order in XML `sequence` elements
 - Added `schemaLocation` to root element and placed publicly accessible XSDs into Github repo

## [1.2.2] - 2020-08-19

 - Printing templates now include @page_dimensions
 - Forced secure SSL ciphers for requests
 - `examples/try_api_call.rb` refactored to be more versatile (download XSDs [:do not work], pritn_selected_combinations)

## [1.2.0] - 2020-06-07

 - **Breaking** Introducing new Printing templates, improved some template names and scopes
 - Added options `custom_card_number` and `print_options` to `Configuration`

## [1.1.0] - 2020-05-28

 - Introducing new API documentation from Czech Post
 - Added service `ParcelSyncSender` service which uses newly discovered `parcelsServiceSync` API endpoint
 - Renamed `ParcelSender` to `ParcelAsyncSender` . And created deprecating clone `ParcelSender`, so no Breaking change! If You usit it calls `ParcelAsyncSender` and displays deprecation message.

## [1.0.3] - 2020-05-20

 - Added Czech Post service  DiscountForOnlinePosting.
 - **Breaking**: Renamed Post service "Size" classes `CzechPostB2bClient::PostServices::Size???` to `CzechPostB2bClient::PostServices::ParcelSize???` (eg. : `CzechPostB2bClient::PostServices::ParcelSizeXL`)
  I know, that I have **breaking** in every new version, I hope You are not fast enough.

## [1.0.2] - 2020-05-08

 - Added Czech Post services as classes, not just list in docs.
 - **Breaking**: Renamed methods `CzechPostB2bClient::PrintingTemplate.all_template_classes` and `CzechPostB2bClient::ResponseCodes.all_code_classes` to  `CzechPostB2bClient::PrintingTemplate.all_classes`  , and `CzechPostB2bClient::ResponseCodes.all_classes`

## [1.0.0] - 2020-03-19

Production ready release

### Fixed
### Changed
### Added
- All the stuff

