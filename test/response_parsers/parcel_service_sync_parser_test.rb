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

      def test_it_handle_parcels_out_of_evidence
        # it seems, that data are stored for 1 year at Czech Post
        skip
      end

      def test_it_handles_errors_in_response
        parser = CzechPostB2bClient::ResponseParsers::GetResultParcelsParser.call(xml: b2b_bad_response)
        assert parser.success?
        assert_equal expected_failed_batch_struct, parser.result
      end

      def expected_ok_struct
        {
          request: { created_at: Time.parse('2020-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '33' },
          response: { created_at: Time.parse('2020-02-18T16:00:34.913Z'), state: { code: 1, text: 'OK' } },
          parcel: { '12345' => { parcel_code: 'DR0404870003M',
                                 states: [{ code: 408, text: 'INFO_ADDRESS_WAS_MODIFIED' }],
                                 print: { pdf_content: 'very big pdf extracted from base64 string',
                                          state: { code: 1, text: 'OK' } } } }
        }
      end

      def expected_failed_batch_struct
        {
          request: { created_at: Time.parse('2020-03-13T14:55:20.000Z'),
                     contract_id: '25195667001',
                     request_id: '1' },
          response: { created_at: Time.parse('2020-03-13T14:57:12.000Z'), state: { code: 19, text: 'BATCH_INVALID' } },
          parcels: { 'package_1' => { parcel_code: nil, states: [{ code: 104, text: 'INVALID_WEIGHT' },
                                                                 { code: 261, text: 'MISSING_SIZE_CATEGORY' }] },
                     'package_2' => { parcel_code: nil, states: [{ code: 104, text: 'INVALID_WEIGHT' },
                                                                 { code: 261, text: 'MISSING_SIZE_CATEGORY' }] },
                     'package_3' => { parcel_code: nil, states: [{ code: 310, text: 'INVALID_PREFIX' }] } }
        }
      end

      def b2b_ok_response
        fixture_response_xml('parcelServiceSync_ok.xml')
      end

      def b2b_bad_response
        fixture_response_xml('getResultParcels_with_errors.xml')
      end
    end
  end
end