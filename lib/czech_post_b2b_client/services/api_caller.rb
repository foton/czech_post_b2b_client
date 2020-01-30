# frozen_string_literal: true
require 'openssl'
require 'net/http'

module CzechPostB2bClient
  module Services
    class ApiCaller < SteppedService::Base

      DEFAULT_OPTIONS = {
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        keep_alive_timeout: 30,
        #cert: OpenSSL::X509::Certificate.new(File.read('./client.cert.pem')),
        #key: OpenSSL::PKey::RSA.new(File.read('./client.key.pem'))
      }

      def initialize(endpoint_path: , xml: )
        @endpoint_path = endpoint_path
        @request_xml = xml
      end

      def steps
        %i[call_api handle_response]
      end

      private

      attr_accessor :request_xml, :response, :endpoint_path

      def call_api
        request = Net::HTTP::Post.new service_uri.request_uri, headers
        request.body = request_xml

        self.response = https_conn.request(request)
      end

      def handle_response
        @result = OpenStruct.new(code: response.code, xml: response.body, error: nil)
      end

      def https_conn
        @https_conn ||= Net::HTTP.start(service_uri.host, service_uri.port, DEFAULT_OPTIONS)
      end

      def service_uri
        @service_uri ||= URI.parse(configuration.b2b_api_base_uri + endpoint_path)
      end

      def headers
        {} # {'Content-Type': 'text/json'}
      end

      def configuration
        CzechPostB2bClient.configuration
      end
    end
  end
end
