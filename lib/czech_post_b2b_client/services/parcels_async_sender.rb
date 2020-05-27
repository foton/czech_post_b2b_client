# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsAsyncSender < CzechPostB2bClient::Services::Communicator
      attr_reader :sending_data, :parcels

      def initialize(sending_data:, parcels:)
        @sending_data = sending_data
        @parcels = parcels
      end

      private

      def request_builder_args
        { common_data: common_data, parcels: parcels }
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::SendParcelsBuilder
      end

      def api_caller_class
        CzechPostB2bClient::Services::ApiCaller
      end

      def response_parser_class
        CzechPostB2bClient::ResponseParsers::SendParcelsParser
      end

      def common_data
        data_from_config.merge(sending_data)
      end

      def data_from_config
        {
          contract_id: configuration.contract_id,
          customer_id: configuration.customer_id,
          sending_post_office_code: configuration.sending_post_office_code
        }
      end

      def endpoint_path
        '/sendParcels'
      end

      def build_result_from(response_hash)
        OpenStruct.new(transaction_id: response_hash.dig(:async_result, :transaction_id),
                       processing_end_expected_at: response_hash.dig(:async_result, :processing_end_expected_at))
      end
    end
  end
end
