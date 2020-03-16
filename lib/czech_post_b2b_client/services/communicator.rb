# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class Communicator < CzechPostB2bClient::Services::Orchestrator
      def steps
        %i[build_request call_api process_response]
      end

      private

      attr_accessor :request_xml, :response_xml, :response_hash

      def build_request
        self.request_xml = result_of_subservice(request_builder: request_builder_args)
      end

      def call_api
        self.response_xml = result_of_subservice(api_caller: { endpoint_path: endpoint_path, xml: request_xml }).xml
      end

      def process_response
        self.response_hash = result_of_subservice(response_parser: { xml: response_xml })
        @result = build_result_from(response_hash) unless response_hash.nil?
      end
    end
  end
end
