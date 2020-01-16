# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetParcelsPrintingParserTest < Minitest::Test
      def response_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <v1:b2bSyncResponse xmlns:v1="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:v1_1="https://b2b.postaonline.cz/schema/POLServices-v1">
            <v1:header>
              <v1:timeStamp>2016-02-18T16:00:34.913Z</v1:timeStamp>
              <v1:b2bRequestHeader>
                <v1:idExtTransaction>64</v1:idExtTransaction>
                <v1:timeStamp>2016-03-12T10:00:34.573Z</v1:timeStamp>
                <v1:idContract>25195667001</v1:idContract>
              </v1:b2bRequestHeader>
            </v1:header>
            <v1:serviceData>
              <v1_1:getParcelStateResponse>
                <v1_1:parcel>
                  <v1_1:idParcel>BA0109964075X</v1_1:idParcel>
                  <v1_1:parcelType>BA</v1_1:parcelType> <!-- string, what is allowed here?! -->
                  <v1_1:weight>0.690</v1_1:weight>
                  <v1_1:amount>111.5</v1_1:amount> <!-- castka dobirky -->
                  <v1_1:currency>CZK</v1_1:currency> <!-- mena dobirky -->
                  <v1_1:quantityParcel>2</v1_1:quantityParcel> <!-- pocet kusu -->
                  <v1_1:depositTo>2015-09-02</v1_1:depositTo> <!-- datum ulozeni do -->
                  <v1_1:timeDeposit>15</v1_1:timeDeposit>     <!-- ulozni doba (asi dny) -->
                  <v1_1:countryOfOrigin>Banánistán</v1_1:countryOfOrigin> <!-- string, what is allowed here?! -->
                  <v1_1:countryOfDestination>Banánistán</v1_1:countryOfDestination> <!-- string, what is allowed here?! -->
                  <v1_1:states>
                    <v1_1:state>
                      <v1_1:id>21</v1_1:id> <!-- string, what is allowed here?! -->
                      <v1_1:date>2015-09-02</v1_1:date>
                      <v1_1:text>Podání zásilky.</v1_1:text>
                      <v1_1:postCode>26701</v1_1:postCode> <!-- PSC kde stav nastal -->
                      <v1_1:name>Králův Dvůr u Berouna</v1_1:name> <!-- nazev provozovny kde stav nastal -->
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-F</v1_1:id>
                      <v1_1:date>2015-09-03</v1_1:date>
                      <v1_1:text>Vstup zásilky na SPU.</v1_1:text>
                      <v1_1:postCode>22200</v1_1:postCode>
                      <v1_1:name>SPU Praha 022</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-I</v1_1:id>
                      <v1_1:date>2015-09-03</v1_1:date>
                      <v1_1:text>Výstup zásilky z SPU.</v1_1:text>
                      <v1_1:postCode>22200</v1_1:postCode>
                      <v1_1:name>SPU Praha 022</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-B</v1_1:id>
                      <v1_1:date>2015-09-03</v1_1:date>
                      <v1_1:text>Přeprava zásilky k dodací poště.</v1_1:text>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>51</v1_1:id>
                      <v1_1:date>2015-09-04</v1_1:date>
                      <v1_1:text>Příprava zásilky k doručení.</v1_1:text>
                      <v1_1:postCode>25607</v1_1:postCode>
                      <v1_1:name>Depo Benešov 70</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>53</v1_1:id>
                      <v1_1:date>2015-09-04</v1_1:date>
                      <v1_1:text>Doručování zásilky.</v1_1:text>
                      <v1_1:postCode>25756</v1_1:postCode>
                      <v1_1:name>Neveklov</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>91</v1_1:id>
                      <v1_1:date>2015-09-04</v1_1:date>
                      <v1_1:text>Dodání zásilky.</v1_1:text>
                      <v1_1:postCode>25756</v1_1:postCode>
                      <v1_1:name>Neveklov</v1_1:name>
                    </v1_1:state>
                  </v1_1:states>
                </v1_1:parcel>
                <v1_1:parcel>
                  <v1_1:idParcel>BA0146149139X</v1_1:idParcel>
                  <v1_1:parcelType>BA</v1_1:parcelType>
                  <v1_1:weight>0.686</v1_1:weight>
                  <v1_1:amount>0</v1_1:amount>
                  <v1_1:currency></v1_1:currency>
                  <v1_1:timeDeposit>15</v1_1:timeDeposit>
                  <v1_1:states>
                    <v1_1:state>
                      <v1_1:id>21</v1_1:id>
                      <v1_1:date>2015-08-18</v1_1:date>
                      <v1_1:text>Podání zásilky.</v1_1:text>
                      <v1_1:postCode>53703</v1_1:postCode>
                      <v1_1:name>Chrudim 3</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-F</v1_1:id>
                      <v1_1:date>2015-08-18</v1_1:date>
                      <v1_1:text>Vstup zásilky na SPU.</v1_1:text>
                      <v1_1:postCode>53020</v1_1:postCode>
                      <v1_1:name>SPU Pardubice 02</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-I</v1_1:id>
                      <v1_1:date>2015-08-19</v1_1:date>
                      <v1_1:text>Výstup zásilky z SPU.</v1_1:text>
                      <v1_1:postCode>22200</v1_1:postCode>
                      <v1_1:name>SPU Praha 022</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-B</v1_1:id>
                      <v1_1:date>2015-08-19</v1_1:date>
                      <v1_1:text>Přeprava zásilky k dodací poště.</v1_1:text>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>51</v1_1:id>
                      <v1_1:date>2015-08-20</v1_1:date>
                      <v1_1:text>Příprava zásilky k doručení.</v1_1:text>
                      <v1_1:postCode>25607</v1_1:postCode>
                      <v1_1:name>Depo Benešov 70</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>53</v1_1:id>
                      <v1_1:date>2015-08-20</v1_1:date>
                      <v1_1:text>Doručování zásilky.</v1_1:text>
                      <v1_1:postCode>25756</v1_1:postCode>
                      <v1_1:name>Neveklov</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>43</v1_1:id>
                      <v1_1:date>2015-08-20</v1_1:date>
                      <v1_1:text>E-mail odesílateli - dodání zásilky.</v1_1:text>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>91</v1_1:id>
                      <v1_1:date>2015-08-20</v1_1:date>
                      <v1_1:text>Dodání zásilky.</v1_1:text>
                      <v1_1:postCode>25756</v1_1:postCode>
                      <v1_1:name>Neveklov</v1_1:name>
                    </v1_1:state>
                  </v1_1:states>
                </v1_1:parcel>
                </v1_1:getParcelStateResponse>
              </v1:serviceData>
          </v1:b2bSyncResponse>
        XML
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

      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelStateParser.call(response_xml)
        assert parser.success?
        assert_equal expected_struct, parser.result
      end

      def test_it_handle_parcels_out_of_evidence
        # it seems, that data are stored for 1 year at Czech Post
        skip
      end

      def expected_parcels_hash # rubocop:disable Metrics/MethodLength
        {
          'BA0109964075X' => {
            parcel_type: 'BA',
            weight_in_kg: 0.690,  # hopefully it is in KG
            cash_on_delivery_amount: 111.5,
            cash_on_delivery_currency: 'CZK',
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
            cash_on_delivery_amount: 0.0,
            cash_on_delivery_currency: '',
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
