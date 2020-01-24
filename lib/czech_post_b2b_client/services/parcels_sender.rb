# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsSender < SteppedService::Base
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
        builder = request_builder_class.call(common_data: common_data, parcels: parcels)
        self.request_xml = builder.result if builder.success?
      end

      def call_api
        api_caller = CzechPostB2bClient::Services::ApiCaller.call(endpoint_url, request_xml)
        self.response_xml = api_caller.result.xml if api_caller.success?
      end

      def process_response
        response_parser = response_parser_class.call(response_xml)
        @result = build_result_from(response_parser.result) if response_parser.success?
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::SendParcelsBuilder
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
          sending_post_office_code: configuration.sending_post_office_code,
        }
      end

      def configuration
        CzechPostB2bClient.configuration
      end

      def endpoint_url
        'https://b2b.postaonline.cz/services/POLService/v1/sendParcels'
      end

      def build_result_from(response_hash)
        OpenStruct.new(transaction_id: response_hash.dig(:async_result, :transaction_id),
                       processing_end_expected_at: response_hash.dig(:async_result, :processing_end_expected_at))
      end
    end
  end
end
