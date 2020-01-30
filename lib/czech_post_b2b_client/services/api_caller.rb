# frozen_string_literal: true
require 'openssl'
require 'net/http'

module CzechPostB2bClient
  module Services
    class ApiCaller < SteppedService::Base
      def initialize(endpoint_path:, xml:)
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
        @result = OpenStruct.new(code: response.code.to_i, xml: response.body, error: nil)
      end

      def https_conn
        @https_conn ||= Net::HTTP.start(service_uri.host, service_uri.port, connection_options)
      end

      def service_uri
        @service_uri ||= URI.parse(configuration.b2b_api_base_uri + endpoint_path)
      end

      def headers
        {'Content-Type': 'text/xml'}
      end

      def connection_options
        {
          use_ssl: true,
          verify_mode: OpenSSL::SSL::VERIFY_PEER,
          keep_alive_timeout: 30,
          cert: OpenSSL::X509::Certificate.new(File.read(configuration.certificate_path)),
          # cert_password: configuration.certificate_password,
          key: OpenSSL::PKey::RSA.new(File.read(configuration.private_key_path), configuration.private_key_password),
          cert_store: post_signum_ca_store
        }
      end

      def configuration
        CzechPostB2bClient.configuration
      end

      def post_signum_ca_store
        store = OpenSSL::X509::Store.new
        store.set_default_paths # Optional method that will auto-include the system CAs.

        #store.add_cert(OpenSSL::X509::Certificate.new(File.read("/path/to/ca2.crt")))
        store.add_file(File.join(CzechPostB2bClient.certs_path, 'postsignum_qca4_root.pem'))
        store.add_file(File.join(CzechPostB2bClient.certs_path, 'postsignum_vca5_sub.pem'))
        store
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

