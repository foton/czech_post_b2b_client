# frozen_string_literal: true

require 'test_helper'
require 'date'
require 'time'

module CzechPostB2bClient
  module Test
    class SendParcelsBuilderTest < Minitest::Test
      attr_reader :transaction_id

      def setup
        @expected_build_time_str = '2019-12-12T12:34:56.789+01:00'
        @contract_id = '123456I'
        @request_id = 42
        @build_time = Time.parse(@expected_build_time_str)

        @transaction_id = '1C6921F2-0153-4000-E000-21F00AA06329'

        CzechPostB2bClient.configure do |config|
          config.contract_id = @contract_id
        end
      end

      def test_it_build_correct_xml
        Time.stub(:now, @build_time) do
          builder = CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.call(common_data: common_data,
                                                                                 parcels: parcels_data,
                                                                                 request_id: @request_id)
          assert builder.success?
          assert_equal expected_xml, builder.result
        end
      end

      # def test_it_assings_request_id_if_it_is_not_present
      #   Time.stub(:now, @build_time) do
      #     builder = CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.call(transaction_id: transaction_id)

      #     assert builder.success?
      #     assert_equal expected_xml.gsub(">#{@request_id}</", '>1</'), builder.result
      #   end
      # end

      # def test_it_requires_at_least_one_parcel
      #   builder = CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.call(transaction_id: '')

      #   assert builder.failed?
      #   assert_includes builder.errors[:transaction_id], 'Must be present!'
      # end

      # def test_it_allows_max_1000_parcels
      #   builder = CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.call(transaction_id: '')

      #   assert builder.failed?
      #   assert_includes builder.errors[:transaction_id], 'Must be present!'
      # end

      # def test_it_validates_cash_on_delivery_params
      #   builder = CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.call(transaction_id: '')

      #   assert builder.failed?
      #   assert_includes builder.errors[:transaction_id], 'Must be present!'
      # end

      # def test_it_validates_parcel_data
      #   builder = CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.call(transaction_id: '')

      #   assert builder.failed?
      #   assert_includes builder.errors[:transaction_id], 'Must be present!'
      # end

      # def test_it_validates_sender_data
      #   builder = CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.call(transaction_id: '')

      #   assert builder.failed?
      #   assert_includes builder.errors[:transaction_id], 'Must be present!'
      # end




      private

      def common_data
        {
          customer_id: 'U219',
          parcels_sending_date:  Date.new(2016, 02, 12),
          sending_post_office_code: 28002,
          sending_post_office_location_number: 98765, # optional
          close_requests_batch: false, # we want to use more requests for one bulk delivery  (default is true, one request = one delivery)
          sender: sender_data,
          cash_on_delivery: cash_on_delivery_data, # optional
          contract_number: 'string10',
          franking_machine_number: 'string10f'
        }
      end

      def parcels_data
        [max_parcel_data] # 1-1000
      end

      def sender_data
        {
          address: {
            company_name: 'Oriflame',
            addition_to_name: 'perfume', # optional
            street: 'V olšinách',
            house_number: '16',
            sequence_number: '82',
            city_part: 'Strašnice',
            city: 'Praha',
            post_code: 10000,
            country_iso_code: 'CZ'
          },
          mobile_phone: '+420777888999', # optional
          phone: '+420027912191',  # optional
          email: 'rehor.jan@cpost.cz',  # optional
          custom_card_number: 'string_20' # optional
        }
      end

      def cash_on_delivery_data
        {
          address: {
            company_name: 'Oriflame',
            street: 'V olšinách',
            house_number: '16',
            sequence_number: '82',
            city_part: 'Strašnice',
            city: 'Praha',
            post_code: 10000,
            country_iso_code: 'CZ'
          },
          bank_account: '123456-1234567890/1234'
        }
      end

      def max_parcel_data
        {
          params: parcel_data_params, # required
          cash_on_delivery: { amount: 12345.678, currency_iso_code: 'CZK' },
          services: ['43', '44', 's3'],
          addressee: addresee_data,
          document_addressee: addresee_data, # 0-X
          custom_declaration: parcel_data_custom_delaration # 0-1
        }
      end

      def parcel_data_params
        {
          record_id: 'my_id', # REQUIRED; purpose? something like custom_id ?
          parcel_code: '123456789W', # (will be assigned by CzechPost if not presnt?), string13
          parcel_code_prefix: 'RR', # # REQUIRED; string 2; something like `parcel_type`?
          weight_in_kg: 12345.678, # hopefuly in KG
          insured_value: 123456789.01,
          voucher_variable_symbol: 1234567890,
          parcel_variable_symbol:  2345678910,
          specific_symbol: '1234567890',
          parcel_order: 2,
          parcels_count: 3,
          note: 'string_50',
          note2: 'string_50_2',
          note_for_print: 'string_50_print',
          lenght: 123,
          width: 231,
          height: 312,
          mrn_code: '15CZ65000021QMDZN0', # string18, what it is MRN code?
          reference_number: 'string30', # cislo jednaci
          pallets_count: 1, # 1-99
          documents_to_sign_count: 'string30', # he?
          score: 'string30', # napocet ceny sluzby
          zpro_order_number: 'string11', # cislo objednavky ZPRO
          days_to_deposit: 's2', # pocet dni pro vraceni zasilky
        }
      end

      def addresee_data
        # all items optional?!
        {
          address: {
            firts_name: 'Ján',
            last_name: 'Nový',
            company_name: 'Empire observatory',
            addition_to_name: 'state building',
            street: 'West 34th Street',
            house_number: '20',
            sequence_number: '',
            city_part: 'Manhattan',
            city: 'New York',
            post_code: 10118,
            country_iso_code: 'US',
            subcountry_iso_code: 'US-NY'
          },
          addresee_id: 'string20',
          addresee_type: 'F',  # string2; => <subject>
          ic: 1234567890,
          dic: 'AB1234567890',
          addresee_specification: 'date_of_birth', # string15, specifikace adresata, napr. datum narozeni
          bank_account: '234561-2345678901/2341',
          mobile_phone: 'do not have, kidding',
          phone: '+1(212)710-1364',
          email: 'jan.novy@ny.us',
          custom_card_number: 'string_20',
          advice_informations: Array.new(6) {|i| "string10_#{i}"},
          advice_note: 'string15'
        }
      end

      def parcel_data_custom_delaration
        {
          category: 's2', # REQUIRED, kategorie zásilky
          note: 'string30',
          value_currency_iso_code: 'CZK', # REQUIRED, ISO kod meny celni hodnoty
          content_descriptions: [ # 1- 20x; popis obsahu zasilky
            {
              order: 1, # # REQUIRED, 1-20
              description: 'string50: heavy metal', # # REQUIRED, popis zboží
              quantity: 'string50: many', # REQUIRED
              weight_in_kg: 3.777, # REQUIRED
              value: 123456789.01, # REQUIRED
              hs_code: 'string6', # REQUIRED
              origin_country_iso_code: 'CS' # REQUIRED, string2
            },
            {
              order: 2, # # REQUIRED, 1-20
              description: 'string50: light metal', # # REQUIRED, popis zboží
              quantity: 'string50: few', # REQUIRED
              weight_in_kg: 0.777, # REQUIRED
              value: 123.01, # REQUIRED
              hs_code: 'string6', # REQUIRED
              origin_country_iso_code: 'CS' # REQUIRED, string2
            }
          ]
        }
      end

      def expected_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <b2bRequest xmlns="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:ns2="https://b2b.postaonline.cz/schema/POLServices-v1">
            <header>
              <idExtTransaction>#{@request_id}</idExtTransaction>
              <timeStamp>#{@expected_build_time_str}</timeStamp>
              <idContract>#{@contract_id}</idContract>
            </header>
            <serviceData>
              <ns2:sendParcels>
                <ns2:doParcelHeader>
                  <ns2:transmissionDate>12.02.2016</ns2:transmissionDate>
                  <ns2:customerID>U219</ns2:customerID>
                  <ns2:postCode>28002</ns2:postCode>
                  <ns2:senderAddress>
                    <ns2:companyName>Oriflame</ns2:companyName>
                    <ns2:aditionAddress>perfume</ns2:companyName>
                    <ns2:street>V olšinách</ns2:street>
                    <ns2:houseNumber>16</ns2:houseNumber>
                    <ns2:sequenceNumber>82</ns2:sequenceNumber>
                    <ns2:partCity>Strašnice</ns2:partCity>
                    <ns2:city>Praha</ns2:city>
                    <ns2:zipCode>10000</ns2:zipCode>
                    <ns2:isoCountry>CZ</ns2:isoCountry>
                  </ns2:senderAddress>
                  <ns2:codAddress>
                    <ns2:companyName>Oriflame</ns2:companyName>
                    <ns2:street>V olšinách</ns2:street>
                    <ns2:houseNumber>16</ns2:houseNumber>
                    <ns2:sequenceNumber>82</ns2:sequenceNumber>
                    <ns2:partCity>Strašnice</ns2:partCity>
                    <ns2:city>Praha</ns2:city>
                    <ns2:zipCode>10000</ns2:zipCode>
                    <ns2:isoCountry>CZ</ns2:isoCountry>
                  </ns2:codAddress>
                  <ns2:codBank>
                    <ns2:prefixAccount>123456</ns2:prefixAccount>
                    <ns2:account>1234567890</ns2:account>
                    <ns2:bank>1234</ns2:bank>
                  </ns2:codBank>
                  <ns2:senderContacts>
                    <ns2:mobileNumber>+420777888999</ns2:mobileNumber>
                    <ns2:phoneNumber>+420027912191</ns2:phoneNumber>
                    <ns2:emailAddress>rehor.jan@cpost.cz</ns2:emailAddress>
                  </ns2:senderContacts>
                  <ns2:senderCustCardNum>string_20</ns2:senderCustCardNum>
                  <ns2:locationNumber>98765</ns2:locationNumber>
                </ns2:doParcelHeader>
                <ns2:doParcelData>
                  <ns2:doParcelParams>
                    <ns2:recordID>my_id</ns2:recordID>
                    <ns2:parcelCode>123456789W</ns2:parcelCode>
                    <ns2:prefixParcelCode>RR</ns2:prefixParcelCode>
                    <ns2:weight>12345.678</ns2:weight>
                    <ns2:insuredValue>123456789.01</ns2:insuredValue>
                    <ns2:amount>12345.678</ns2:amount>
                    <ns2:currency>CZK</ns2:currency>
                    <ns2:vsVoucher>1234567890</ns2:vsVoucher>
                    <ns2:vsParcel>2345678910</ns2:vsParcel>
                    <ns2:sequenceParcel>2</ns2:sequenceParcel>
                    <ns2:quantityParcel>3</ns2:quantityParcel>
                    <ns2:note>string50</ns2:note>
                    <ns2:notePrint>string_50_print</ns2:notePrint>
                    <ns2:length>123</ns2:length>
                    <ns2:width>231</ns2:width>
                    <ns2:height>312</ns2:height>
                    <ns2:mrn>15CZ65000021QMDZN0</ns2:mrn>
                    <ns2:referenceNumber>string30</ns2:referenceNumber>
                    <ns2:pallets>1</ns2:pallets>
                    <ns2:specSym>1234567890</ns2:specSym>
                    <ns2:note2>string50_2</ns2:note2>
                    <ns2:numSign>string30</ns2:numSign>
                    <ns2:score>string30</ns2:score>
                    <ns2:orderNumberZPRO>string11</ns2:orderNumberZPRO>
                    <ns2:returnNumDays>s2</ns2:returnNumDays>
                  </ns2:doParcelParams>
                  <ns2:doParcelServices>
                    <ns2:service>43</ns2:service>
                  </ns2:doParcelServices>
                  <ns2:doParcelServices>
                    <ns2:service>44</ns2:service>
                  </ns2:doParcelServices>
                  <ns2:doParcelServices>
                    <ns2:service>s3</ns2:service>
                  </ns2:doParcelServices>
                  <ns2:doParcelAddress>
                    <ns2:recordID>string20</ns2:recordID>
                    <ns2:firstName>Ján</ns2:firstName>
                    <ns2:surname>Nový</ns2:surname>
                    <ns2:companyName>Empire observatory</ns2:companyName>
                    <ns2:aditionAddress>state building</ns2:aditionAddress>
                    <ns2:subject>F</ns2:subject>
                    <ns2:ic>1234567890</ns2:ic>
                    <ns2:dic>AB1234567890</ns2:dic>
                    <ns2:specification>date_of_birth</ns2:specification>
                    <ns2:street>West 34th Street</ns2:street>
                    <ns2:houseNumber>20</ns2:houseNumber>
                    <ns2:sequenceNumber></ns2:sequenceNumber>
                    <ns2:partCity>Manhattan</ns2:partCity>
                    <ns2:city>New York</ns2:city>
                    <ns2:zipCode>10118</ns2:zipCode>
                    <ns2:isoCountry>US</ns2:isoCountry>
                    <ns2:subIsoCountry>US</ns2:subIsoCountry>
                    <ns2:bank>2341</ns2:bank>
                    <ns2:prefixAccount>234561</ns2:prefixAccount>
                    <ns2:account>2345678901</ns2:account>
                    <ns2:mobileNumber>do not have, kidding</ns2:mobileNumber>
                    <ns2:phoneNumber>+1(212)710-1364</ns2:phoneNumber>
                    <ns2:emailAddress>jan.novy@ny.us</ns2:emailAddress>
                    <ns2:custCardNum>string_20</ns2:custCardNum>
                    <ns2:adviceInformation1>string10_1</ns2:adviceInformation1>
                    <ns2:adviceInformation2>string10_2</ns2:adviceInformation2>
                    <ns2:adviceInformation3>string10_3</ns2:adviceInformation3>
                    <ns2:adviceInformation4>string10_4</ns2:adviceInformation4>
                    <ns2:adviceInformation5>string10_5</ns2:adviceInformation5>
                    <ns2:adviceInformation6>string10_6</ns2:adviceInformation6>
                    <ns2:adviceNote>string15</ns2:adviceNote>
                  </ns2:doParcelAddress>
                  <ns2:doParcelAddressDocument>
                    <ns2:recordID>string20</ns2:recordID>
                    <ns2:firstName>Ján</ns2:firstName>
                    <ns2:surname>Nový</ns2:surname>
                    <ns2:companyName>Empire observatory</ns2:companyName>
                    <ns2:aditionAddress>state building</ns2:aditionAddress>
                    <ns2:subject>F</ns2:subject>
                    <ns2:ic>1234567890</ns2:ic>
                    <ns2:dic>AB1234567890</ns2:dic>
                    <ns2:specification>date_of_birth</ns2:specification>
                    <ns2:street>West 34th Street</ns2:street>
                    <ns2:houseNumber>20</ns2:houseNumber>
                    <ns2:sequenceNumber></ns2:sequenceNumber>
                    <ns2:partCity>Manhattan</ns2:partCity>
                    <ns2:city>New York</ns2:city>
                    <ns2:zipCode>10118</ns2:zipCode>
                    <ns2:isoCountry>US</ns2:isoCountry>
                    <ns2:subIsoCountry>US</ns2:subIsoCountry>
                    <ns2:bank>2341</ns2:bank>
                    <ns2:prefixAccount>234561</ns2:prefixAccount>
                    <ns2:account>2345678901</ns2:account>
                    <ns2:mobileNumber>do not have, kidding</ns2:mobileNumber>
                    <ns2:phoneNumber>+1(212)710-1364</ns2:phoneNumber>
                    <ns2:emailAddress>jan.novy@ny.us</ns2:emailAddress>
                    <ns2:custCardNum>string_20</ns2:custCardNum>
                    <ns2:adviceInformation1>string10_1</ns2:adviceInformation1>
                    <ns2:adviceInformation2>string10_2</ns2:adviceInformation2>
                    <ns2:adviceInformation3>string10_3</ns2:adviceInformation3>
                    <ns2:adviceInformation4>string10_4</ns2:adviceInformation4>
                    <ns2:adviceInformation5>string10_5</ns2:adviceInformation5>
                    <ns2:adviceInformation6>string10_6</ns2:adviceInformation6>
                    <ns2:adviceNote>string15</ns2:adviceNote>
                  </ns2:doParcelAddressDocument>
                  <ns2:doParcelCustomsDeclaration>
                    <ns2:category>s2</ns2:category>
                    <ns2:note>string30</ns2:note>
                    <ns2:customValCur>CZK</ns2:customValCur>
                    <ns2:doParcelCustomsGoods>
                      <ns2:sequence>1</ns2:sequence>
                      <ns2:customCont>string50: heavy metal</ns2:customCont>
                      <ns2:quantity>string50: many</ns2:quantity>
                      <ns2:weight>3.777</ns2:weight>
                      <ns2:customVal>123456789.01</ns2:customVal>
                      <ns2:hsCode>string6</ns2:hsCode>
                      <ns2:iso>CS</ns2:iso>
                    </ns2:doParcelCustomsGoods>
                    <ns2:doParcelCustomsGoods>
                      <ns2:sequence>2</ns2:sequence>
                      <ns2:customCont>string50: light metal</ns2:customCont>
                      <ns2:quantity>string50: few</ns2:quantity>
                      <ns2:weight>0.777</ns2:weight>
                      <ns2:customVal>123.01</ns2:customVal>
                      <ns2:hsCode>string6</ns2:hsCode>
                      <ns2:iso>CS</ns2:iso>
                    </ns2:doParcelCustomsGoods>
                  </ns2:doParcelCustomsDeclaration>
                </ns2:doParcelData>
              </ns2:sendParcels>
            </serviceData>
          </b2bRequest>
        XML
      end
    end
  end
end
