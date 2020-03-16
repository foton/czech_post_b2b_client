# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetParcelsPrintingParserTest < Minitest::Test
      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser.call(xml: fixture_response_xml('getParcelsPrinting_ok.xml'))

        assert parser.success?
        assert_equal expected_ok_struct, parser.result
      end

      def test_it_handles_errors_in_response
        skip "not yet really prepared"
        parser = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser.call(xml: fixture_response_xml('getParcelsPrinting_with_errors.xml'))
        assert parser.success?
        assert_equal expected_failed_batch_struct, parser.result
      end


      def expected_ok_struct
        {
          printings: {
            options: {
              customer_id: 'EE89',
              contract_number: '12345678',
              template_id: 20, # 7 => adresni stitek (alonz) - samostatny
              margin_in_mm: { top: 2, left: 1 },
              position_order: 3 },
            pdf_content: 'very big pdf extracted from base64 string'
          },
          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z'), state: { code: 0, text: 'OK' } }
        }
      end

      def expected_failed_batch_struct
        {
          printings: {
            options: {
              customer_id: 'EE89',
              contract_number: '12345678',
              template_id: 20, # 7 => adresni stitek (alonz) - samostatny
              margin_in_mm: { top: 2, left: 1 },
              position_order: 3 },
            pdf_content: nil
          },
          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z'), state: { code: 100, text: 'INVALID_PARCEL_CODE' } }
        }
      end
    end
  end
end


# <complexType name="doPrintingHeaderResult">
# <annotation>
#     <documentation xml:lang="cs">Hlavičková data výsledku tisku</documentation>
# </annotation>
# <sequence>
#     <element name="doPrintingHeader" type="tns:doPrintingHeader" minOccurs="0">
#   <annotation>
#       <documentation xml:lang="cs">Vlastní hlavička pro tisk</documentation>
#   </annotation>
#     </element>
#     <element name="doPrintingStateResponse" type="tns:doParcelStateResponse">
#   <annotation>
#       <documentation xml:lang="cs">
#     Stav tisku:     responseCode    responseText                Popis
#                       ==============================================================================================
#                       1            OK                                              Data parametrů zpracování v pořádku
#                       2            INTERNALL_ERROR                                 Jiná chyba systému
#                       100            INVALID_PARCEL_CODE                             Neplatné ID zásilky
#                       378            INVALID_PREFIX_COMBINATION                      Zásilka je chybně přiřazena k id tiskové šablony
#                       379            PARCEL_DOES_NOT_MEET_THE_REQUIREMENTS_FORM      Parametry zásilky nesplňují podmínky požadovaného formuláře
#                       380            NO_CONTRACT_SERVICE_RETURN_RECEIPT              K formuláři není sjednána smlouva ke službě Dodejka
#       </documentation>
#   </annotation>
#     </element>
# </sequence>
#   </complexType>

