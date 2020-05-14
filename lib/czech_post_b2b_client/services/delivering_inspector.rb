# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class DeliveringInspector < CzechPostB2bClient::Services::Communicator
      attr_reader :parcel_codes

      def initialize(parcel_codes:)
        @parcel_codes = parcel_codes
      end

      private

      def request_builder_args
        { parcel_codes: parcel_codes }
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::GetParcelStateBuilder
      end

      def api_caller_class
        CzechPostB2bClient::Services::ApiCaller
      end

      def response_parser_class
        CzechPostB2bClient::ResponseParsers::GetParcelStateParser
      end

      def endpoint_path
        '/getParcelState'
      end

      def build_result_from(response_hash)
        puts("RESPONSE_HASH: #{response_hash}")
        result_hash = {}
        response_hash[:parcels].each_pair do |parcel_code, delivering_hash|
          result_hash[parcel_code] = {
            deposited_until: delivering_hash[:deposited_until],
            deposited_for_days: delivering_hash[:deposited_for_days],
            current_state: delivering_hash[:states].last,
            all_states: delivering_hash[:states]
          }
        end
        puts("RESULT_HASH: #{result_hash}")
        result_hash
      end
    end
  end
end
