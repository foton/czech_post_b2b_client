# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class TimePeriodStatisticator < CzechPostB2bClient::Services::Communicator
      attr_reader :from_date, :to_date

      TimePeriodStatisticatorResult = Struct.new(:requests, :imported_parcels, keyword_init: true)
      TimePeriodStatisticatorRequestsResult = Struct.new(:total, :with_errors, :successful, keyword_init: true)

      def initialize(from_date:, to_date:)
        super()
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
        TimePeriodStatisticatorResult.new(
          requests: TimePeriodStatisticatorRequestsResult.new(total: imports[:requested],
                                                              with_errors: imports[:with_errors],
                                                              successful: imports[:successful]),
          imported_parcels: imports[:imported_parcels]
        )
      end
    end
  end
end
