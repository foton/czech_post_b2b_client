# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class AddressSheetsGenerator < CzechPostB2bClient::Services::Communicator
      attr_reader :parcel_codes, :options

      def initialize(parcel_codes:, options: {})
        @parcel_codes = parcel_codes
        @options = options
      end

      def steps
        super + %i[check_for_state_errors]
      end

      private

      def request_builder_args
        { parcel_codes: parcel_codes, options: options }
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder
      end

      def api_caller_class
        CzechPostB2bClient::Services::ApiCaller
      end

      def response_parser_class
        CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser
      end

      def endpoint_path
        '/getParcelsPrinting'
      end

      def build_result_from(response_hash)
        OpenStruct.new(pdf_content: response_hash.dig(:printings, :pdf_content),
                       state_text: response_hash.dig(:response, :state, :text),
                       state_code: response_hash.dig(:response, :state, :code))
      end

      def check_for_state_errors
        return if result.state_code == CzechPostB2bClient::ResponseCodes::Ok.code
        binding.pry
        r_code = CzechPostB2bClient::ResponseCodes.new_by_code(result.state_code)

        errors.add(:response_state, r_code.to_s)

        fail! unless r_code.info?
      end
    end
  end
end
