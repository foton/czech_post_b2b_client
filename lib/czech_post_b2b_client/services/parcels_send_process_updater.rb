# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsSendProcessUpdater < CzechPostB2bClient::Services::Orchestrator
      attr_reader :transaction_id

      def initialize(transaction_id:)
        @transaction_id = transaction_id
      end

      def steps
        %i[build_request call_api process_response]
      end

      private

      attr_accessor :request_xml, :response_xml

      def build_request
        self.request_xml = result_of_subservice(request_builder: { transaction_id: transaction_id })
      end

      def call_api
        self.response_xml = result_of_subservice(api_caller: { endpoint_path: endpoint_path, xml: request_xml }).xml
      end

      def process_response
        response_hash = result_of_subservice(response_parser: { xml: response_xml })
        @result = build_result_from(response_hash) unless response_hash.nil?
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder
      end

      def api_caller_class
        CzechPostB2bClient::Services::ApiCaller
      end

      def response_parser_class
        CzechPostB2bClient::ResponseParsers::GetResultParcelsParser
      end

      def endpoint_path
        '/getResultParcels'
      end

      def build_result_from(response_hash)
        OpenStruct.new(parcels_hash: response_hash[:parcels])
      end
    end
  end
end
