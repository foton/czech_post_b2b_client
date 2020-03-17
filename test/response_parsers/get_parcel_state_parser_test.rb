# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetParcelStateParserTest < Minitest::Test

      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelStateParser.call(xml: fixture_response_xml('getParcelState_ok.xml'))
        assert parser.success?
        assert_equal expected_struct, parser.result
      end

      def test_it_handle_parcels_out_of_evidence
        # it seems, that data are stored for 1 year at Czech Post
        parser = CzechPostB2bClient::ResponseParsers::GetParcelStateParser.call(xml: fixture_response_xml('getParcelState_not_actually_send_package.xml'))
        assert parser.success?
        assert_equal expected_out_of_evidence_struct, parser.result
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

      def expected_out_of_evidence_struct
        { parcels: { 'BA0305100114L' => {
                        parcel_type: 'BA',
                        weight_in_kg: 0.0,
                        cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
                        pieces: 1,
                        deposited_until: nil,
                        deposited_for_days: 15,
                        country_of_origin: '',
                        country_of_destination: '',
                        states: [{ id: '-3',
                                   date:  Date.new(2020,3,17),
                                   text: 'Zásilka tohoto podacího čísla není v evidenci.',
                                   post_code: nil,
                                   post_name: nil }] }},
          request: { created_at: Time.parse('2020-03-17T08:58:05.898Z'),
                     contract_id: '25195667001',
                     request_id: '63' },
          response: { created_at: Time.parse('2020-03-17T09:58:06.379Z') }
        }
      end

      def expected_parcels_hash # rubocop:disable Metrics/MethodLength
        {
          'BA0109964075X' => {
            parcel_type: 'BA',
            weight_in_kg: 0.690,  # hopefully it is in KG
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
            weight_in_kg: 0.686,  # hopefully it is in KG
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
