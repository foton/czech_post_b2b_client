# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class TimePeriodStatisticator < CzechPostB2bClient::Services::Communicator
      attr_reader :from_date, :to_date

      def initialize(from_date:, to_date:)
        @from_date = from_date
        @to_date = to_date
      end

      private

      def request_builder_args
        { from_date: from_date, to_date: to_date }
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::GetStatsBuilder
      end

      def api_caller_class
        CzechPostB2bClient::Services::ApiCaller
      end

      def response_parser_class
        CzechPostB2bClient::ResponseParsers::GetStatsParser
      end

      def endpoint_path
        '/getStats'
      end

      def build_result_from(response_hash)
        imports = response_hash[:imports]
        OpenStruct.new(requests: OpenStruct.new(total: imports[:requested],
                                                with_errors: imports[:with_errors],
                                                successful: imports[:successful]),
                       imported_parcels: imports[:imported_parcels])
      end
    end
  end
end
