# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsSender < SteppedService::Base
      attr_accessor :request_xml, :response_xml

      def initialize(sending_data:, parcels:)

      end

      def steps
        %i[build_request call_api process_response]
      end

      def build_request
        self.request_xml = request_builder_class.call(common_data: {}, parcels: [])
      end

      def call_api
        # TODO
        self.response_xml = ''
      end

      def process_response
        response_parser_class.call(response_xml)
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::SendParcelsBuilder
      end

      def response_parser_class
        CzechPostB2bClient::ResponseParsers::SendParcelsParser
      end
    end
  end
end
