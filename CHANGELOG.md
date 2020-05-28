# Changelog

All changes to the gem are documented here.

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


