# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetResultParcelsParserTest < Minitest::Test
      def test_it_parses_ok_response_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetResultParcelsParser.call(xml: fixture_response_xml('getResultParcels_all_ok.xml'))
        assert parser.success?
        assert_equal expected_struct, parser.result
      end

      def test_it_handle_parcels_out_of_evidence
        # it seems, that data are stored for 1 year at Czech Post
        skip
      end

      def test_it_handles_errors_in_response
        skip
        parser = CzechPostB2bClient::ResponseParsers::GetResultParcelsParser.call(xml: fixture_response_xml('getResultParcels_with_errors.xml'))
      end

      def expected_struct
        {
          parcels: expected_parcels_hash,
          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '64' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z') }
        }
      end

      def expected_parcels_hash # rubocop:disable Metrics/MethodLength
        {
          '12345' => {
            parcel_code: 'DR1010101010B',
            state_code: 1,
            state_text: 'OK',
          },
          '12346' => {
            parcel_code: 'DR1010101011B',
            state_code: 1,
            state_text: 'OK',
          }
        }
      end

      def expected_states_array_4075
        # rubocop:disable Metrics/LineLength

        # order is exactly as in XML, there is no ordering key
        [
          { id: '21', date: Date.parse('2015-09-02'), text: 'Podání zásilky.', post_code: '26701', post_name: 'Králův Dvůr u Berouna' },
          { id: '-F', date: Date.parse('2015-09-03'), text: 'Vstup zásilky na SPU.', post_code: '22200', post_name: 'SPU Praha 022' },
          { id: '-I', date: Date.parse('2015-09-03'), text: 'Výstup zásilky z SPU.', post_code: '22200', post_name: 'SPU Praha 022' },
          { id: '-B', date: Date.parse('2015-09-03'), text: 'Přeprava zásilky k dodací poště.', post_code: nil, post_name: nil },
          { id: '51', date: Date.parse('2015-09-04'), text: 'Příprava zásilky k doručení.', post_code: '25607', post_name: 'Depo Benešov 70' },
          { id: '53', date: Date.parse('2015-09-04'), text: 'Doručování zásilky.', post_code: '25756', post_name: 'Neveklov' },
          { id: '91', date: Date.parse('2015-09-04'), text: 'Dodání zásilky.', post_code: '25756', post_name: 'Neveklov' }
        ]
      end

      def expected_states_array_9139
        [
          { id: '21', date: Date.parse('2015-08-18'), text: 'Podání zásilky.', post_code: '53703', post_name: 'Chrudim 3' },
          { id: '-F', date: Date.parse('2015-08-18'), text: 'Vstup zásilky na SPU.', post_code: '53020', post_name: 'SPU Pardubice 02' },
          { id: '-I', date: Date.parse('2015-08-19'), text: 'Výstup zásilky z SPU.', post_code: '22200', post_name: 'SPU Praha 022' },
          { id: '-B', date: Date.parse('2015-08-19'), text: 'Přeprava zásilky k dodací poště.', post_code: nil, post_name: nil },
          { id: '51', date: Date.parse('2015-08-20'), text: 'Příprava zásilky k doručení.', post_code: '25607', post_name: 'Depo Benešov 70' },
          { id: '53', date: Date.parse('2015-08-20'), text: 'Doručování zásilky.', post_code: '25756', post_name: 'Neveklov' },
          { id: '43', date: Date.parse('2015-08-20'), text: 'E-mail odesílateli - dodání zásilky.', post_code: nil, post_name: nil },
          { id: '91', date: Date.parse('2015-08-20'), text: 'Dodání zásilky.', post_code: '25756', post_name: 'Neveklov' }
        ]
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
