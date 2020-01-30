# frozen_string_literal: true
require 'openssl'
require 'net/http'

module CzechPostB2bClient
  module Services
    class ApiCaller < SteppedService::Base
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
        @https_conn ||= Net::HTTP.start(service_uri.host, service_uri.port, connection_options)
      end

      def service_uri
        @service_uri ||= URI.parse(configuration.b2b_api_base_uri + endpoint_path)
      end

      def headers
        {} # {'Content-Type': 'text/json'}
      end

      def connection_options
        {
          use_ssl: true,
          verify_mode: OpenSSL::SSL::VERIFY_PEER,
          keep_alive_timeout: 30,
          cert: OpenSSL::X509::Certificate.new(File.read(configuration.certificate_path)),
          # cert_password: configuration.certificate_password,
          key: OpenSSL::PKey::RSA.new(File.read(configuration.private_key_path), configuration.private_key_password)
        }
      end

      def configuration
        CzechPostB2bClient.configuration
      end
    end
  end
end

# # You can specify custom CA certs. If your production system only connects to
# # one particular server, you should specify these, and bundle them with your
# # app, so that you don't depend OS level pre-installed certificates in the
# # production environment.
# http = Net::HTTP.new("verysecure.com", 443)
# http.use_ssl = true
# http.verify_mode = OpenSSL::SSL::VERIFY_PEER

# store = OpenSSL::X509::Store.new
# store.set_default_paths # Optional method that will auto-include the system CAs.
# store.add_cert(OpenSSL::X509::Certificate.new(File.read("/path/to/ca1.crt")))
# store.add_cert(OpenSSL::X509::Certificate.new(File.read("/path/to/ca2.crt")))
# store.add_file("/path/to/ca3.crt") # Alternative syntax for adding certs.
# http.cert_store = store


# # Client certificate example. Some servers use this to authorize the connecting
# # client, i.e. you. The server you connect to gets the certificate you specify,
# # and they can use it to check who signed the certificate, and use the
# # certificate fingerprint to identify exactly which certificate you're using.
# http = Net::HTTP.new("verysecure.com", 443)
# http.use_ssl = true
# http.verify_mode = OpenSSL::SSL::VERIFY_PEER
# http.key = OpenSSL::PKey::RSA.new(File.read("/path/to/client.key"), "optional passphrase argument")
# http.cert = OpenSSL::X509::Certificate.new(File.read("/path/to/client.crt"))
