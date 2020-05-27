# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class DeliveringInspectorTest < Minitest::Test
      include CzechPostB2bClient::Test::CommunicatorServiceTestingBase

      def setup
        setup_configuration

        @endpoint_path = '/getParcelState'

        @tested_service_class = CzechPostB2bClient::Services::DeliveringInspector
        @tested_service_args = { parcel_codes: parcel_codes }

        @builder_service_class = CzechPostB2bClient::RequestBuilders::GetParcelStateBuilder
        @parser_service_class = CzechPostB2bClient::ResponseParsers::GetParcelStateParser
        @builder_expected_args = { parcel_codes: parcel_codes }
        @builder_expected_errors = { parcel_codes: ['No codes'] }
        @fake_response_parser_result = {
          parcels: expected_parser_parcels_hash
        }.merge(fake_response_parser_result_shared_part)
      end

      def builder_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |parcel_codes:|
          parcel_codes == expected_args[:parcel_codes]
        end
        fake
      end

      def succesful_call_asserts(tested_service)
        assert_equal expected_inspector_result, tested_service.result
        assert_equal '91', tested_service.result['BA0109964075X'][:current_state][:id] # sanity checks
      end

      def parcel_codes
        @parcel_codes ||= expected_parser_parcels_hash.keys
      end

      def expected_inspector_result
        @expected_inspector_result ||= begin
          inspector_hash = {}
          expected_parser_parcels_hash.each_pair do |parcel_code, delivering_hash|
            inspector_hash[parcel_code] = {
              deposited_until: delivering_hash[:deposited_until],
              deposited_for_days: delivering_hash[:deposited_for_days],
              current_state: delivering_hash[:states].last,
              all_states: delivering_hash[:states]
            }
          end
          inspector_hash
        end
      end

      def expected_parser_parcels_hash # rubocop:disable Metrics/MethodLength
        {
          'BA0109964075X' => {
            parcel_type: 'BA',
            weight_in_kg: 0.690, # hopefully it is in KG
            cash_on_delivery: { amount: 111.5, currency_iso_code: 'CZK' },
            pieces: 2,
            deposited_until: Date.new(2015, 9, 2),
            deposited_for_days: 15,
            country_of_origin: 'Banánistán',
            country_of_destination: 'Banánistán',
            states: expected_states_array_4075
          },
          'BA0146149139X' => {
            parcel_type: 'BA',
            weight_in_kg: 0.686, # hopefully it is in KG
            cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
            pieces: 1,
            deposited_until: nil,
            deposited_for_days: 15,
            country_of_origin: '',
            country_of_destination: '',
            states: expected_states_array_9139
          }
        }
      end

      def expected_states_array_4075
        # rubocop:disable Layout/LineLength

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
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
