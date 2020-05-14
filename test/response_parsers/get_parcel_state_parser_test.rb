# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetParcelStateParserTest < Minitest::Test # rubocop:disable Metrics/ClassLength
      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelStateParser.call(xml: b2b_ok_response)
        assert parser.success?, "Failed parser: #{parser.errors}"
        assert_equal expected_ok_struct, parser.result
      end

      def test_it_parses_real_response_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelStateParser.call(xml: b2b_real_response)
        assert parser.success?, "Failed parser: #{parser.errors}"
        assert_equal expected_real_parcels_struct, parser.result
      end

      def test_it_handle_parcels_out_of_evidence
        # it seems, that data are stored for 1 year at Czech Post
        parser = CzechPostB2bClient::ResponseParsers::GetParcelStateParser.call(xml: b2b_out_of_evidence_response)
        assert parser.success?, "Failed parser: #{parser.errors}"
        assert_equal expected_out_of_evidence_struct, parser.result
      end

      def test_it_handle_empty_parcels
        parser = CzechPostB2bClient::ResponseParsers::GetParcelStateParser.call(xml: b2b_no_parcels_response)
        assert parser.success?, "Failed parser: #{parser.errors}"

        no_parcels_struct = {
          request: { created_at: Time.parse('2020-03-19T08:40:25.541Z'), contract_id: '25195667001', request_id: '42' },
          response: { created_at: Time.parse('2020-03-19T09:40:26.099Z') },
          parcels: {}
        }

        assert_equal no_parcels_struct, parser.result
      end

      # rubocop:disable Metrics/LineLength
      def expected_ok_struct # rubocop:disable Metrics/MethodLength
        {
          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'), contract_id: '25195667001', request_id: '64' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z') },
          parcels: {
            'BA0109964075X' => {
              parcel_type: 'BA',
              weight_in_kg: 0.690, # hopefully it is in KG
              cash_on_delivery: { amount: 111.5, currency_iso_code: 'CZK' },
              pieces: 2,
              deposited_until: Date.new(2015, 9, 2),
              deposited_for_days: 15,
              country_of_origin: 'Banánistán',
              country_of_destination: 'Banánistán',
              states: [ # order is exactly as in XML, there is no ordering key
                { id: '21', date: Date.parse('2015-09-02'), text: 'Podání zásilky.', post_code: '26701', post_name: 'Králův Dvůr u Berouna' },
                { id: '-F', date: Date.parse('2015-09-03'), text: 'Vstup zásilky na SPU.', post_code: '22200', post_name: 'SPU Praha 022' },
                { id: '-I', date: Date.parse('2015-09-03'), text: 'Výstup zásilky z SPU.', post_code: '22200', post_name: 'SPU Praha 022' },
                { id: '-B', date: Date.parse('2015-09-03'), text: 'Přeprava zásilky k dodací poště.', post_code: nil, post_name: nil },
                { id: '51', date: Date.parse('2015-09-04'), text: 'Příprava zásilky k doručení.', post_code: '25607', post_name: 'Depo Benešov 70' },
                { id: '53', date: Date.parse('2015-09-04'), text: 'Doručování zásilky.', post_code: '25756', post_name: 'Neveklov' },
                { id: '91', date: Date.parse('2015-09-04'), text: 'Dodání zásilky.', post_code: '25756', post_name: 'Neveklov' }
              ]
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
              states: [
                { id: '21', date: Date.parse('2015-08-18'), text: 'Podání zásilky.', post_code: '53703', post_name: 'Chrudim 3' },
                { id: '-F', date: Date.parse('2015-08-18'), text: 'Vstup zásilky na SPU.', post_code: '53020', post_name: 'SPU Pardubice 02' },
                { id: '-I', date: Date.parse('2015-08-19'), text: 'Výstup zásilky z SPU.', post_code: '22200', post_name: 'SPU Praha 022' },
                { id: '-B', date: Date.parse('2015-08-19'), text: 'Přeprava zásilky k dodací poště.', post_code: nil, post_name: nil },
                { id: '51', date: Date.parse('2015-08-20'), text: 'Příprava zásilky k doručení.', post_code: '25607', post_name: 'Depo Benešov 70' },
                { id: '53', date: Date.parse('2015-08-20'), text: 'Doručování zásilky.', post_code: '25756', post_name: 'Neveklov' },
                { id: '43', date: Date.parse('2015-08-20'), text: 'E-mail odesílateli - dodání zásilky.', post_code: nil, post_name: nil },
                { id: '91', date: Date.parse('2015-08-20'), text: 'Dodání zásilky.', post_code: '25756', post_name: 'Neveklov' }
              ]
            }
          }
        }
      end

      def expected_out_of_evidence_struct
        {
          request: { created_at: Time.parse('2020-03-17T08:58:05.898Z'), contract_id: '25195667001', request_id: '63' },
          response: { created_at: Time.parse('2020-03-17T09:58:06.379Z') },
          parcels: {
            'BA0305100114L' => {
              parcel_type: 'BA',
              weight_in_kg: 0.0,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: 15,
              country_of_origin: '',
              country_of_destination: '',
              states: [
                { id: '-3', date: Date.new(2020, 3, 17), text: 'Zásilka tohoto podacího čísla není v evidenci.', post_code: nil, post_name: nil }
              ]
            }
          }
        }
      end

      def expected_real_parcels_struct # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        {
          request: { created_at: Time.parse('2020-03-19T07:53:21.416Z'), contract_id: '25195667001', request_id: '64' },
          response: { created_at: Time.parse('2020-03-19T08:53:23.195Z') },
          parcels: {
            'RR442097828CZ' => {
              parcel_type: 'RR',
              weight_in_kg: 0.415,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: nil,
              country_of_origin: 'Česká republika',
              country_of_destination: 'Spojené státy americké',
              states: [
                { id: '-M', date: Date.parse('2020-03-12'), text: 'Obdrženy údaje k zásilce.', post_code: nil, post_name: nil },
                { id: '21', date: Date.parse('2020-03-12'), text: 'Zásilka převzata do přepravy.', post_code: '14000', post_name: 'Praha 4' },
                { id: 'C1', date: Date.parse('2020-03-13'), text: 'Odeslání zásilky do země určení.', post_code: nil, post_name: nil }
              ]
            },
            'RR442097831CZ' => {
              parcel_type: 'RR',
              weight_in_kg: 0.396,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: nil,
              country_of_origin: 'Česká republika',
              country_of_destination: 'Kanada',
              states: [
                { id: '-M', date: Date.parse('2020-03-12'), text: 'Obdrženy údaje k zásilce.', post_code: nil, post_name: nil },
                { id: '21', date: Date.parse('2020-03-12'), text: 'Zásilka převzata do přepravy.', post_code: '14000', post_name: 'Praha 4' },
                { id: 'C1', date: Date.parse('2020-03-13'), text: 'Odeslání zásilky do země určení.', post_code: nil, post_name: nil }
              ]
            },
            'RR442097859CZ' => {
              parcel_type: 'RR',
              weight_in_kg: 0.079,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: nil,
              country_of_origin: 'Česká republika',
              country_of_destination: 'Spojené státy americké',
              states: [
                { id: '-M', date: Date.parse('2020-03-12'), text: 'Obdrženy údaje k zásilce.', post_code: nil, post_name: nil },
                { id: '21', date: Date.parse('2020-03-12'), text: 'Zásilka převzata do přepravy.', post_code: '14000', post_name: 'Praha 4' },
                { id: 'C1', date: Date.parse('2020-03-13'), text: 'Odeslání zásilky do země určení.', post_code: nil, post_name: nil }
              ]
            },
            'RR442120685CZ' => {
              parcel_type: 'RR',
              weight_in_kg: 0.096,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: 15,
              country_of_origin: '',
              country_of_destination: '',
              states: [
                { id: '-M', date: Date.parse('2020-03-17'), text: 'Obdrženy údaje k zásilce.', post_code: nil, post_name: nil },
                { id: '21', date: Date.parse('2020-03-17'), text: 'Zásilka převzata do přepravy.', post_code: '14000', post_name: 'Praha 4' }
              ]
            },
            'RR442120699CZ' => {
              parcel_type: 'RR',
              weight_in_kg: 0.096,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: 15,
              country_of_origin: '',
              country_of_destination: '',
              states: [
                { id: '-M', date: Date.parse('2020-03-17'), text: 'Obdrženy údaje k zásilce.', post_code: nil, post_name: nil },
                { id: '21', date: Date.parse('2020-03-17'), text: 'Zásilka převzata do přepravy.', post_code: '14000', post_name: 'Praha 4' },
                { id: '51', date: Date.parse('2020-03-19'), text: 'Příprava zásilky k doručení.', post_code: '14300', post_name: 'Praha 412' }
              ]
            },
            'RR442120711CZ' => {
              parcel_type: 'RR',
              weight_in_kg: 0.075,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: 15,
              country_of_origin: '',
              country_of_destination: '',
              states: [
                { id: '-M', date: Date.parse('2020-03-17'), text: 'Obdrženy údaje k zásilce.', post_code: nil, post_name: nil },
                { id: '21', date: Date.parse('2020-03-17'), text: 'Zásilka převzata do přepravy.', post_code: '14000', post_name: 'Praha 4' },
                { id: '8V', date: Date.parse('2020-03-19'), text: 'Uložení zásilky - sjednaná výhrada odnášky.', post_code: '54301', post_name: 'Vrchlabí 1' },
                { id: '91', date: Date.parse('2020-03-19'), text: 'Dodání zásilky.', post_code: '54301', post_name: 'Vrchlabí 1' }
              ]
            },
            'RR442097845CZ' => {
              parcel_type: 'RR',
              weight_in_kg: 0.1,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: 15,
              country_of_origin: '',
              country_of_destination: '',
              states: [
                { id: '-M', date: Date.parse('2020-03-12'), text: 'Obdrženy údaje k zásilce.', post_code: nil, post_name: nil },
                { id: '21', date: Date.parse('2020-03-12'), text: 'Zásilka převzata do přepravy.', post_code: '14000', post_name: 'Praha 4' },
                { id: '51', date: Date.parse('2020-03-16'), text: 'Příprava zásilky k doručení.', post_code: '60012', post_name: 'Depo Brno 73' },
                { id: '53', date: Date.parse('2020-03-16'), text: 'Doručování zásilky.', post_code: '60012', post_name: 'Depo Brno 73' },
                { id: '91', date: Date.parse('2020-03-16'), text: 'Dodání zásilky.', post_code: '60012', post_name: 'Depo Brno 73' }
              ]
            },
            'RR442097862CZ' => {
              parcel_type: 'RR',
              weight_in_kg: 0.441,
              cash_on_delivery: { amount: 0.0, currency_iso_code: '' },
              pieces: 1,
              deposited_until: nil,
              deposited_for_days: 15,
              country_of_origin: '',
              country_of_destination: '',
              states: [
                { id: '-M', date: Date.parse('2020-03-12'), text: 'Obdrženy údaje k zásilce.', post_code: nil, post_name: nil },
                { id: '21', date: Date.parse('2020-03-12'), text: 'Zásilka převzata do přepravy.', post_code: '14000', post_name: 'Praha 4' },
                { id: '51', date: Date.parse('2020-03-16'), text: 'Příprava zásilky k doručení.', post_code: '41800', post_name: 'dodejna II Bílina' },
                { id: '53', date: Date.parse('2020-03-16'), text: 'Doručování zásilky.', post_code: '41800', post_name: 'dodejna II Bílina' },
                { id: '91', date: Date.parse('2020-03-16'), text: 'Dodání zásilky.', post_code: '41800', post_name: 'dodejna II Bílina' }
              ]
            }
          }
        }
      end
      # rubocop:enable Metrics/LineLength

      def b2b_ok_response
        fixture_response_xml('getParcelState_ok.xml')
      end

      def b2b_real_response
        fixture_response_xml('getParcelState_ok_real.xml')
      end

      def b2b_out_of_evidence_response
        fixture_response_xml('getParcelState_not_actually_send_package.xml')
      end

      def b2b_no_parcels_response
        fixture_response_xml('getParcelState_real_no_parcels.xml')
      end
    end
  end
end
