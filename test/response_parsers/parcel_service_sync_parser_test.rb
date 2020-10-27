# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class ParcelServiceSyncParserTest < Minitest::Test
      def test_it_parses_ok_response_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::ParcelServiceSyncParser.call(xml: b2b_ok_response)
        assert parser.success?
        assert_equal expected_ok_struct, parser.result
      end

      def test_it_handles_errors_in_response
        parser = CzechPostB2bClient::ResponseParsers::ParcelServiceSyncParser.call(xml: b2b_bad_response)

        assert parser.success?
        assert_equal expected_failed_batch_struct, parser.result
      end

      def test_it_handles_mixed_errors_in_response
        parser = CzechPostB2bClient::ResponseParsers::ParcelServiceSyncParser.call(xml: b2b_bad_response_with_tracking_code)

        assert parser.success?

        assert_equal expected_mixed_failed_batch_struct, parser.result
      end

      def expected_ok_struct
        {
          request: { created_at: Time.parse('2020-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '33' },
          response: { created_at: Time.parse('2020-02-18T16:00:34.913Z'), state: { code: 1, text: 'OK' } },
          parcel: { '12345' => { parcel_code: 'DR0404870003M',
                                 states: [{ code: 408, text: 'INFO_ADDRESS_WAS_MODIFIED' }],
                                 printings: { pdf_content: 'very big pdf extracted from base64 string',
                                              state: { code: 1, text: 'OK' } } } }
        }
      end

      def expected_failed_batch_struct
        {
          request: { created_at: Time.parse('2020-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '33' },
          response: { created_at: Time.parse('2020-02-18T16:00:34.913Z'), state: { code: 19, text: 'BATCH_INVALID' } },
          parcel: { '12345' => { parcel_code: nil,
                                 states: [{ code: 104, text: 'INVALID_WEIGHT' },
                                          { code: 261, text: 'MISSING_SIZE_CATEGORY' }],
                                 printings: nil } }
        }
      end

      def expected_mixed_failed_batch_struct
        {
          request: { created_at: Time.parse('2020-10-27 10:47:42.401 +0100'),
                     contract_id: '356936003',
                     request_id: '1' },
          response: { created_at: Time.parse('2020-10-27 10:47:44.111 UTC'), state: { code: 19, text: 'BATCH_INVALID' } },
          parcel: { '62752' => { parcel_code: 'BX0305100675L',
                                 states: [{ code: 408, text: 'INFO_ADDRESS_WAS_MODIFIED' },
                                          { code: 310, text: 'INVALID_PREFIX' }],
                                 printings: nil } }
        }
      end

      def b2b_ok_response
        fixture_response_xml('parcelServiceSync_ok.xml')
      end

      def b2b_bad_response
        fixture_response_xml('parcelServiceSync_with_errors.xml')
      end

      def b2b_bad_response_with_tracking_code
        fixture_response_xml('parcelServiceSync_with_errors_2.xml')
      end
    end
  end
end
