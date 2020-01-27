# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ApiCaller < SteppedService::Base
      def initialize(uri: , xml: )
        @endpoint_uri = :uri
        @request_xml = :xml
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
