# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class TimePeriodStatisticatorTest < Minitest::Test
      include CzechPostB2bClient::Test::CommunicatorServiceTestingBase

      attr_reader :expected_statistics

      def setup
        setup_configuration
        @from_date = Date.parse('2019-01-01')
        @to_date = Date.parse('2020-02-02')

        @expected_statistics = { requested: 16,
                                 with_errors: 13,
                                 successful: 3,
                                 imported_parcels: 43 }
        @endpoint_path = '/getStats'

        @tested_service_class = CzechPostB2bClient::Services::TimePeriodStatisticator
        @tested_service_args = { from_date: @from_date, to_date: @to_date }

        @builder_service_class = CzechPostB2bClient::RequestBuilders::GetStatsBuilder
        @parser_service_class = CzechPostB2bClient::ResponseParsers::GetStatsParser
        @builder_expected_args = { from_date: @from_date, to_date: @to_date }
        @builder_expected_errors = { from_date: ['2020-02-30 is nonsence'], to_date: ['2020-13-13 is nonsence'] }
        @fake_response_parser_result = { imports: @expected_statistics }.merge(fake_response_parser_result_shared_part)
      end

      def builder_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |from_date:, to_date:|
          from_date == expected_args[:from_date] && to_date == expected_args[:to_date]
        end
        fake
      end

      def succesful_call_asserts(tested_service)
        requests = tested_service.result.requests
        assert_equal expected_statistics[:requested], requests.total
        assert_equal expected_statistics[:with_errors], requests.with_errors
        assert_equal expected_statistics[:successful], requests.successful
        assert_equal expected_statistics[:imported_parcels], tested_service.result.imported_parcels
      end
    end
  end
end
