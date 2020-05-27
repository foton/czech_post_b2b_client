# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class ParcelsSubmissionCloserTest < Minitest::Test
      include CzechPostB2bClient::Test::CommunicatorServiceTestingBase

      attr_reader :transaction_id, :processing_end_expected_at

      def setup
        setup_configuration

        @transaction_id = 'transaction1'
        @processing_end_expected_at = Time.parse('2016-02-25T09:30:03.678Z')
        @endpoint_path = '/sendParcels' # 'https://b2b.postaonline.cz/services/POLService/v1/sendParcels'

        @tested_service_class = CzechPostB2bClient::Services::ParcelsSubmissionCloser
        @tested_service_args = { sending_data: sending_data }

        # ParcelsSubmissionCloser actually do/calls the same thing as ParcelsAsyncSender,
        # but without parcels and with closing tag
        @builder_service_class = CzechPostB2bClient::RequestBuilders::SendParcelsBuilder
        @parser_service_class = CzechPostB2bClient::ResponseParsers::SendParcelsParser
        @builder_expected_args = { common_data: expected_common_closing_data, parcels: [] }
        @builder_expected_errors = { common_data: ['Missing :parcels_sending_date value', 'xxx'] }
        @fake_response_parser_result = {
          async_result: { transaction_id: @transaction_id,
                          processing_end_expected_at: @processing_end_expected_at }
        }.merge(fake_response_parser_result_shared_part)
      end

      def builder_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |common_data:, parcels:|
          common_data == expected_args[:common_data] && parcels == expected_args[:parcels]
        end
        fake
      end

      def succesful_call_asserts(tested_service)
        assert_equal processing_end_expected_at, tested_service.result.processing_end_expected_at
        assert_equal transaction_id, tested_service.result.transaction_id
      end

      def sending_data
        sd = full_common_data.dup
        sd.delete(:contract_id) # taken from config
        sd.delete(:customer_id) # taken from config
        sd.delete(:sending_post_office_code) # taken from config
        sd[:close_requests_batch] = false # THIS WILL BE OVERRIDEN TO FALSE in ParcelsSubmissionCloser
        sd
      end

      def data_from_config
        { contract_id: configuration.contract_id,
          customer_id: configuration.customer_id,
          sending_post_office_code: configuration.sending_post_office_code }
      end

      def expected_common_closing_data
        data_from_config.merge(sending_data).merge(close_requests_batch: true)
      end
    end
  end
end
