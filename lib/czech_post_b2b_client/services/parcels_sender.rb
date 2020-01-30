# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsSender < CzechPostB2bClient::Services::Orchestrator
      attr_reader :sending_data, :parcels

      def initialize(sending_data:, parcels:)
        @sending_data = sending_data
        @parcels = parcels
      end

      def steps
        %i[build_request call_api process_response]
      end

      private

      attr_accessor :request_xml, :response_xml

      def build_request
        self.request_xml = result_of_subservice(request_builder: { common_data: common_data, parcels: parcels })
      end

      def call_api
        self.response_xml = result_of_subservice(api_caller: { endpoint_path: endpoint_path, xml: request_xml }).xml
      end

      def process_response
        response_hash = result_of_subservice(response_parser: { xml: response_xml })
        @result = build_result_from(response_hash) unless response_hash.nil?
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
