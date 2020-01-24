# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ApiCaller < SteppedService::Base
      def initialize(endpoint_url, request_xml)
        @endpoint_url = endpoint_url
        @request_xml = request_xml
      end

      def steps
        %i[call_api recover_from_errors]
      end

      private

      attr_accessor :request_xml, :response_xml

      def call_api
        # TODO
        @result = OpenStruct.new(code: 200, xml: '<>', error: nil)
      end

      def recover_from_errors
      end

    end
  end
end
