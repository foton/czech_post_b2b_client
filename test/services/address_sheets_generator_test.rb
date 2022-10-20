# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class AddressSheetsGeneratorTest < Minitest::Test
      include CzechPostB2bClient::Test::CommunicatorServiceTestingBase

      attr_reader :expected_pdf_content

      def setup
        setup_configuration

        @options = { customer_id: 'EE89',
                     contract_number: '2511327004',
                     template_id: 7, # 7 => adresni stitek (alonz) - samostatny
                     margin_in_mm: { top: 5, left: 3 },
                     position_order: 1 }
        @parcel_codes = %w[RR123456789E RR123456789F RR123456789G]
        @expected_pdf_content = 'very big pdf extracted from base64 string'
        @endpoint_path = '/getParcelsPrinting'

        @tested_service_class = CzechPostB2bClient::Services::AddressSheetsGenerator
        @tested_service_args = { parcel_codes: @parcel_codes, options: @options }

        @builder_service_class = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder
        @parser_service_class = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser
        @builder_expected_args = { parcel_codes: @parcel_codes, options: @options }
        @builder_expected_errors = { parcel_codes: ['No codes'] }
        @fake_response_parser_result = fake_response_parser_result_shared_part
        @fake_response_parser_result.merge!({ printings: { options: @options,
                                                           pdf_content: @expected_pdf_content } })
        @fake_response_parser_result[:response].merge!(state: { code: 1, text: 'OK' })
      end

      def builder_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |parcel_codes:, options:|
          parcel_codes == expected_args[:parcel_codes] && options == expected_args[:options]
        end
        fake
      end

      def succesful_call_asserts(tested_service)
        assert_equal 1, tested_service.result.state_code
        assert_equal 'OK', tested_service.result.state_text
        assert_equal expected_pdf_content, tested_service.result.pdf_content
      end

      def test_it_fails_with_errors_in_response_data # rubocop:disable Metrics/AbcSize
        builder = successful_builder_mock
        api_caller = successful_api_caller_mock
        # parser just pass errors hash, but call/parsing is successful
        parser = parser_mock(expected_args: { xml: fake_api_caller_result.xml },
                             returns: fake_successful_service(parser_result_with_errors))

        builder_service_class.stub(:call, builder) do
          api_caller_service_class.stub(:call, api_caller) do
            parser_service_class.stub(:call, parser) do
              @service = tested_service_class.call(**tested_service_args)
            end
          end
        end

        assert_mock builder
        assert_mock api_caller
        assert_mock parser

        assert service.failure?
        assert_equal response_state_expected_errors, service.errors[:response_state]
      end

      def parser_result_with_errors
        result = fake_response_parser_result_shared_part.merge({}) # to create new hash
        result[:response].merge!(state: { code: 378, text: 'INVALID_PREFIX_COMBINATION' })
        result
      end

      def response_state_expected_errors
        [CzechPostB2bClient::ResponseCodes.new_by_code(378).to_s]
      end
    end
  end
end
