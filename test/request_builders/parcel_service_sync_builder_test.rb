# frozen_string_literal: true

require 'test_helper'
require 'date'
require 'time'

module CzechPostB2bClient
  module Test
    class ParcelServiceSyncBuilderTest < Minitest::Test # rubocop:disable Metrics/ClassLength
      attr_reader :builder_class, :print_params, :customs_document_data

      def setup
        @expected_build_time_str = '2020-05-12T12:34:56.789+01:00'
        @contract_id = '123456I'
        @request_id = 42
        @build_time = Time.parse(@expected_build_time_str)
        @builder_class = CzechPostB2bClient::RequestBuilders::ParcelServiceSyncBuilder

        @print_params = {
          template_id: 21,
          margin_in_mm: { top: 2, left: 1 },
          position_order: 3
        }

        @customs_document_data = { record_id: 'string50',
                                   code: 'st3',
                                   name: 'string35',
                                   id: 'string55' }

        setup_configuration(contract_id: @contract_id)
      end

      def test_it_build_correct_full_xml
        Time.stub(:now, @build_time) do
          builder = builder_class.call(common_data: full_common_data.merge(print_params: print_params),
                                       parcel: full_parcel_data.merge(customs_documents: [customs_document_data]),
                                       request_id: @request_id)

          assert builder.success?, "Should be successful, but have errors #{builder.errors}"
          assert_equal expected_xml, builder.result
        end
      end

      def test_it_build_correct_short_xml
        Time.stub(:now, @build_time) do
          builder = builder_class.call(common_data: short_common_data,
                                       parcel: short_parcel_data,
                                       request_id: @request_id)

          assert builder.success?, "Should be successful, but have errors #{builder.errors}"
          assert_equal expected_short_xml, builder.result
        end
      end

      def test_it_assings_request_id_if_it_is_not_present
        Time.stub(:now, @build_time) do
          builder = builder_class.call(common_data: short_common_data,
                                       parcel: short_parcel_data)

          assert builder.success?, "Should be successful, but have errors #{builder.errors}"
          assert_equal expected_short_xml.gsub(">#{@request_id}</", '>1</'), builder.result
        end
      end

      def test_it_needs_one_parcel_exactly
        builder = builder_class.call(common_data: short_common_data,
                                     parcel: {})

        assert builder.failed?
        expected_errors = ['One parcel is needed!']
        assert_equal expected_errors, builder.errors[:parcel]
      end

      def test_it_handles_submission_closing_tag
        builder = builder_class.call(common_data: short_common_data.merge(close_requests_batch: true),
                                     parcel: short_parcel_data)

        assert builder.success?, "Should be successful, but have errors #{builder.errors}"
        assert builder.result.include?('<ns2:transmissionEnd>true</ns2:transmissionEnd>')
      end

      def test_it_checks_for_required_common_params
        builder = builder_class.call(common_data: {},
                                     parcel: {})

        assert builder.failed?
        %i[parcels_sending_date customer_id sending_post_office_code].each do |key|
          assert_includes builder.errors[:common_data], "Missing value for key { :#{key} }!"
        end
      end

      def test_it_checks_for_required_parcel_params
        parcel_hash = deep_copy(short_parcel_data)
        parcel_hash[:params].merge!({ parcel_id: 'package_no_prefix', parcel_code_prefix: '' })

        builder = builder_class.call(common_data: short_common_data,
                                     parcel: parcel_hash)

        assert builder.failed?
        expected_errors = [
          "Missing value for key { :params => :parcel_code_prefix } for parcel (parcel_id: 'package_no_prefix')!"
        ]
        assert_equal expected_errors, builder.errors[:parcel]
      end

      def test_it_checks_for_required_parcel_address
        parcel_hash = deep_copy(short_parcel_data)
        parcel_hash.delete(:addressee)

        builder = builder_class.call(common_data: short_common_data,
                                     parcel: parcel_hash)

        assert builder.failed?
        expected_errors = [
          "Missing value for key { :addressee => :address => :last_name } for parcel (parcel_id: 'my_id')!",
          "Missing value for key { :addressee => :address => :street } for parcel (parcel_id: 'my_id')!",
          "Missing value for key { :addressee => :address => :house_number } for parcel (parcel_id: 'my_id')!",
          "Missing value for key { :addressee => :address => :city } for parcel (parcel_id: 'my_id')!",
          "Missing value for key { :addressee => :address => :post_code } for parcel (parcel_id: 'my_id')!"
        ]
        assert_equal expected_errors, builder.errors[:parcel]
      end

      private

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
              <ns2:parcelServiceSyncRequest>
                <ns2:doPOLSyncParcelHeader>
                  <ns2:transmissionDate>12.02.2016</ns2:transmissionDate>
                  <ns2:customerID>U219</ns2:customerID>
                  <ns2:postCode>28002</ns2:postCode>
                  <ns2:contractNumber>string10</ns2:contractNumber>
                  <ns2:frankingNumber>string10f</ns2:frankingNumber>
                  <ns2:transmissionEnd>false</ns2:transmissionEnd>
                  <ns2:locationNumber>98765</ns2:locationNumber>
                  <ns2:senderCustCardNum>string_20</ns2:senderCustCardNum>
                  <ns2:printParams>
                    <ns2:idForm>21</ns2:idForm>
                    <ns2:shiftHorizontal>1</ns2:shiftHorizontal>
                    <ns2:shiftVertical>2</ns2:shiftVertical>
                    <ns2:position>3</ns2:position>
                  </ns2:printParams>
                </ns2:doPOLSyncParcelHeader>
                <ns2:doPOLSyncParcelData>
                  <ns2:doPOLSyncParcelParams>
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
                    <ns2:note>string_50</ns2:note>
                    <ns2:notePrint>string_50_print</ns2:notePrint>
                    <ns2:length>123</ns2:length>
                    <ns2:width>231</ns2:width>
                    <ns2:height>312</ns2:height>
                    <ns2:mrn>15CZ65000021QMDZN0</ns2:mrn>
                    <ns2:referenceNumber>string30</ns2:referenceNumber>
                    <ns2:pallets>1</ns2:pallets>
                    <ns2:specSym>1234567890</ns2:specSym>
                    <ns2:note2>string_50_2</ns2:note2>
                    <ns2:numSign>string30</ns2:numSign>
                    <ns2:score>string30</ns2:score>
                    <ns2:orderNumberZPRO>string11</ns2:orderNumberZPRO>
                    <ns2:returnNumDays>s2</ns2:returnNumDays>
                    <ns2:doPOLParcelServices>
                      <ns2:service>4</ns2:service>
                    </ns2:doPOLParcelServices>
                    <ns2:doPOLParcelServices>
                      <ns2:service>L</ns2:service>
                    </ns2:doPOLParcelServices>
                  </ns2:doPOLSyncParcelParams>
                  <ns2:doPOLParcelAddress>
                    <ns2:recordID>string20</ns2:recordID>
                    <ns2:firstName>J\xC3\xA1n</ns2:firstName>
                    <ns2:surname>Nov\xC3\xBD</ns2:surname>
                    <ns2:companyName>Empire observatory</ns2:companyName>
                    <ns2:aditionAddress>state building</ns2:aditionAddress>
                    <ns2:street>West 34th Street</ns2:street>
                    <ns2:houseNumber>20</ns2:houseNumber>
                    <ns2:sequenceNumber>3</ns2:sequenceNumber>
                    <ns2:partCity>Manhattan</ns2:partCity>
                    <ns2:city>New York</ns2:city>
                    <ns2:zipCode>10118</ns2:zipCode>
                    <ns2:isoCountry>US</ns2:isoCountry>
                    <ns2:subIsoCountry>US-NY</ns2:subIsoCountry>
                    <ns2:subject>F</ns2:subject>
                    <ns2:ic>1234567890</ns2:ic>
                    <ns2:dic>AB1234567890</ns2:dic>
                    <ns2:specification>date_of_birth</ns2:specification>
                    <ns2:prefixAccount>234561</ns2:prefixAccount>
                    <ns2:account>2345678901</ns2:account>
                    <ns2:bank>2341</ns2:bank>
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
                  </ns2:doPOLParcelAddress>
                  <ns2:doPOLParcelAddressDocument>
                    <ns2:recordID>string20</ns2:recordID>
                    <ns2:firstName>J\xC3\xA1n</ns2:firstName>
                    <ns2:surname>Nov\xC3\xBD</ns2:surname>
                    <ns2:companyName>Empire observatory</ns2:companyName>
                    <ns2:aditionAddress>state building</ns2:aditionAddress>
                    <ns2:street>West 34th Street</ns2:street>
                    <ns2:houseNumber>20</ns2:houseNumber>
                    <ns2:sequenceNumber>3</ns2:sequenceNumber>
                    <ns2:partCity>Manhattan</ns2:partCity>
                    <ns2:city>New York</ns2:city>
                    <ns2:zipCode>10118</ns2:zipCode>
                    <ns2:isoCountry>US</ns2:isoCountry>
                    <ns2:subIsoCountry>US-NY</ns2:subIsoCountry>
                    <ns2:subject>F</ns2:subject>
                    <ns2:ic>1234567890</ns2:ic>
                    <ns2:dic>AB1234567890</ns2:dic>
                    <ns2:specification>date_of_birth</ns2:specification>
                    <ns2:prefixAccount>234561</ns2:prefixAccount>
                    <ns2:account>2345678901</ns2:account>
                    <ns2:bank>2341</ns2:bank>
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
                  </ns2:doPOLParcelAddressDocument>
                  <ns2:doPOLParcelCustomsDeclaration>
                    <ns2:category>11</ns2:category>
                    <ns2:note>string30</ns2:note>
                    <ns2:customValCur>CZK</ns2:customValCur>
                    <ns2:importerRefNum>CD12345</ns2:importerRefNum>
                    <ns2:doPOLParcelCustomsGoods>
                      <ns2:sequence>1</ns2:sequence>
                      <ns2:customCont>string50: heavy metal</ns2:customCont>
                      <ns2:quantity>string50: many</ns2:quantity>
                      <ns2:weight>3.777</ns2:weight>
                      <ns2:customVal>123456789.01</ns2:customVal>
                      <ns2:hsCode>string6</ns2:hsCode>
                      <ns2:iso>CS</ns2:iso>
                    </ns2:doPOLParcelCustomsGoods>
                    <ns2:doPOLParcelCustomsGoods>
                      <ns2:sequence>2</ns2:sequence>
                      <ns2:customCont>string50: light metal</ns2:customCont>
                      <ns2:quantity>string50: few</ns2:quantity>
                      <ns2:weight>0.777</ns2:weight>
                      <ns2:customVal>123.01</ns2:customVal>
                      <ns2:hsCode>string6</ns2:hsCode>
                      <ns2:iso>CS</ns2:iso>
                    </ns2:doPOLParcelCustomsGoods>
                  </ns2:doPOLParcelCustomsDeclaration>
                  <ns2:doPOLParcelCustomsDocument>
                    <ns2:recordID>string50</ns2:recordID>
                    <ns2:code>st3</ns2:code>
                    <ns2:name>string35</ns2:name>
                    <ns2:id>string55</ns2:id>
                  </ns2:doPOLParcelCustomsDocument>
                </ns2:doPOLSyncParcelData>
              </ns2:parcelServiceSyncRequest>
            </serviceData>
          </b2bRequest>
        XML
      end

      def expected_short_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <b2bRequest xmlns="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:ns2="https://b2b.postaonline.cz/schema/POLServices-v1">
            <header>
              <idExtTransaction>#{@request_id}</idExtTransaction>
              <timeStamp>#{@expected_build_time_str}</timeStamp>
              <idContract>#{@contract_id}</idContract>
            </header>
            <serviceData>
              <ns2:parcelServiceSyncRequest>
                <ns2:doPOLSyncParcelHeader>
                  <ns2:transmissionDate>12.02.2016</ns2:transmissionDate>
                  <ns2:customerID>U219</ns2:customerID>
                  <ns2:postCode>28002</ns2:postCode>
                </ns2:doPOLSyncParcelHeader>
                <ns2:doPOLSyncParcelData>
                  <ns2:doPOLSyncParcelParams>
                    <ns2:recordID>my_id</ns2:recordID>
                    <ns2:prefixParcelCode>RR</ns2:prefixParcelCode>
                  </ns2:doPOLSyncParcelParams>
                  <ns2:doPOLParcelAddress>
                    <ns2:firstName>J\xC3\xA1n</ns2:firstName>
                    <ns2:surname>Nov\xC3\xBD</ns2:surname>
                    <ns2:street>West 34th Street</ns2:street>
                    <ns2:houseNumber>20</ns2:houseNumber>
                    <ns2:partCity>Manhattan</ns2:partCity>
                    <ns2:city>New York</ns2:city>
                    <ns2:zipCode>10118</ns2:zipCode>
                    <ns2:emailAddress>jan.novy@ny.us</ns2:emailAddress>
                  </ns2:doPOLParcelAddress>
                </ns2:doPOLSyncParcelData>
              </ns2:parcelServiceSyncRequest>
            </serviceData>
          </b2bRequest>
        XML
      end
    end
  end
end
