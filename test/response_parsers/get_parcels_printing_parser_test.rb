# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetParcelsPrintingParserTest < Minitest::Test
      def response_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <b2bSyncResponse xmlns="https://b2b.postaonline.cz/schema/B2BCommon-v1"
            xmlns:ns2="https://b2b.postaonline.cz/schema/POLServices-v1">
            <header>
              <timeStamp>2016-02-18T16:00:34.913Z</timeStamp>
              <b2bRequestHeader>
                <idExtTransaction>42</idExtTransaction>
                <timeStamp>2016-03-12T10:00:34.573Z</timeStamp>
                <idContract>25195667001</idContract>
              </b2bRequestHeader>
            </header>
            <serviceData>
              <ns2:getParcelsPrintingResponse>
                <ns2:doPrintingHeaderResult>
                  <ns2:doPrintingHeader>
                    <ns2:customerID>EE89</ns2:customerID>
                    <ns2:contractNumber>12345678</ns2:contractNumber>
                    <ns2:idForm>20</ns2:idForm>
                    <ns2:shiftHorizontal>1</ns2:shiftHorizontal>
                    <ns2:shiftVertical>2</ns2:shiftVertical>
                    <ns2:position>3</ns2:position>
                  </ns2:doPrintingHeader>
                  <ns2:doPrintingStateResponse>
                    <ns2:responseCode>0</ns2:responseCode>
                    <ns2:responseText>OK</ns2:responseText>
                  </ns2:doPrintingStateResponse>
                </ns2:doPrintingHeaderResult>
                <ns2:doPrintingDataResult>
                  <ns2:file>dmVyeSBiaWcgcGRmIGV4dHJhY3RlZCBmcm9tIGJhc2U2NCBzdHJpbmc=</ns2:file>
                </ns2:doPrintingDataResult>
              </ns2:getParcelsPrintingResponse>
            </serviceData>
          </b2bSyncResponse>
        XML
      end

      def expected_struct
        {
          printings: {
            options: {
              customer_package_id: 'EE89',
              contract_number: '12345678',
              template_id: 20, # 7 => adresni stitek (alonz) - samostatny
              margin_in_mm: { top: 2, left: 1 },
              position_order: 3 },
            state: { code: 0, text: 'OK' },
            pdf_content: 'very big pdf extracted from base64 string' },

          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z') }
        }
      end

      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser.call(xml: response_xml)
        assert parser.success?
        assert_equal expected_struct, parser.result
      end
    end
  end
end
