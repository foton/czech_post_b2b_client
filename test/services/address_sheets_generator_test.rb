# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class AddressSheetsGeneratorTest < Minitest::Test
      include CzechPostB2bClient::Test::CommunicatorServiceTestingBase

      attr_reader :expected_pdf_content

      def setup
        setup_configuration

        @options = {
          customer_id: 'EE89',
          contract_number: '2511327004',
          template_id: 7, # 7 => adresni stitek (alonz) - samostatny
          margin_in_mm: { top: 5, left: 3 },
          position_order: 1
        }
        @parcel_codes = %w[RR123456789E RR123456789F RR123456789G]
        @expected_pdf_content = 'very big pdf extracted from base64 string'
        @endpoint_path = '/getParcelsPrinting'

        @tested_service_class = CzechPostB2bClient::Services::AddressSheetsGenerator
        @tested_service_args = { parcel_codes: @parcel_codes, options: @options }

        @builder_service_class = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder
        @parser_service_class = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser
        @builder_expected_args = { parcel_codes: @parcel_codes, options: @options }
        @builder_expected_errors = { parcel_codes: ['No codes'] }
        @fake_response_parser_result = {
          printings: {
            options: @options,
            state: { code: 0, text: 'OK' },
            pdf_content: @expected_pdf_content
          }
        }.merge(fake_response_parser_result_shared_part)
      end

      def builder_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |parcel_codes: , options:|
          parcel_codes == expected_args[:parcel_codes] && options == expected_args[:options]
        end
        fake
      end

      def succesful_call_asserts(tested_service)
        assert_equal 0, tested_service.result.state_code
        assert_equal 'OK', tested_service.result.state_text
        assert_equal expected_pdf_content, tested_service.result.pdf_content
      end
    end
  end
end

