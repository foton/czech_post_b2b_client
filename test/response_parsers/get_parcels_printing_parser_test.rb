# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetParcelsPrintingParserTest < Minitest::Test
      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser.call(xml: fixture_response_xml('getParcelsPrinting_ok.xml'))

        assert parser.success?
        assert_equal expected_struct, parser.result
      end

      def expected_struct
        {
          printings: {
            options: {
              customer_id: 'EE89',
              contract_number: '12345678',
              template_id: 20, # 7 => adresni stitek (alonz) - samostatny
              margin_in_mm: { top: 2, left: 1 },
              position_order: 3 },
            state: { code: 0, text: 'OK' },
            pdf_content: 'very big pdf extracted from base64 string'
          },
          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z') }
        }
      end
    end
  end
end
