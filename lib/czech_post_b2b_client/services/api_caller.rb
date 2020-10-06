# frozen_string_literal: true

require 'openssl'
require 'net/http'

module CzechPostB2bClient
  module Services
    class ApiCaller < SteppedService::Base
      KNOWN_CONNECTION_ERRORS = [
        Timeout::Error,
        Errno::EINVAL,
        Errno::ECONNRESET,
        EOFError,
        SocketError,
        Net::ReadTimeout,
        Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError,
        Net::ProtocolError
      ].freeze

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
        self.response = https_conn.request(request)
      rescue *KNOWN_CONNECTION_ERRORS => e
        handle_connection_error(e)
      end

      def handle_response
        CzechPostB2bClient.logger.debug("CzechPost B2B RESPONSE: #{response} with body:\n#{response.body}")

        @result = ::OpenStruct.new(code: response.code.to_i, xml: response.body)
        return unless b2b_error?

        errors.add(:b2b, b2b_error_text)
        fail!
      end

      def https_conn
        @https_conn ||= Net::HTTP.start(service_uri.host, service_uri.port, connection_options)
      end

      def request
        request = Net::HTTP::Post.new service_uri.request_uri, headers
        request.body = request_xml

        debug_msg = "CzechPost B2B REQUEST: #{request} to #{service_uri.request_uri}" \
                    " with headers: #{headers}\n and body:\n#{request.body}"
        CzechPostB2bClient.logger.debug(debug_msg)

        request
      end

      def service_uri
        @service_uri ||= URI.parse(configuration.b2b_api_base_uri + endpoint_path)
      end

      def headers
        { 'Content-Type': 'text/xml' }
      end

      def connection_options
        {
          use_ssl: true,
          verify_mode: OpenSSL::SSL::VERIFY_PEER,
          keep_alive_timeout: 30,
          ciphers: secure_and_available_ciphers,
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

        # store.add_cert(OpenSSL::X509::Certificate.new(File.read("/path/to/ca2.crt")))
        store.add_file(File.join(CzechPostB2bClient.certs_path, 'postsignum_qca4_root.pem'))
        store.add_file(File.join(CzechPostB2bClient.certs_path, 'postsignum_vca5_sub.pem'))
        store
      end

      def b2b_error?
        result&.xml&.include?('B2BFaultMessage')
      end

      def b2b_error_text
        err_code_without_namespace_regexp = %r{<(?:\w+\:)?errorCode>(\d+)</(?:\w+\:)?errorCode>}
        error_match = result.xml.match(err_code_without_namespace_regexp)
        return 'error code not found in XML' unless error_match

        error_code = error_match[1].to_i
        error_details = result.xml.match(%r{<(?:\w+\:)?errorDescription>(.*)</(?:\w+\:)?errorDescription>})
        error = CzechPostB2bClient::B2BErrors.new_by_code(error_code, error_details[1])
        return "error code [#{error_code}] is unknown" unless error

        error.message
      end

      def handle_connection_error(error)
        @result = OpenStruct.new(code: 500, xml: '')
        errors.add(:connection, "#{error.class} > #{service_uri} - #{error}")
        fail!
      end

      def secure_and_available_ciphers
        # Available non-weak suites for b2b.postaonline.cz (https://www.ssllabs.com/ssltest/analyze.html?d=b2b.postaonline.cz)
        # TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (0xc030)   ECDH secp384r1 (eq. 7680 bits RSA)   FS	256
        # TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (0xc02f)   ECDH secp384r1 (eq. 7680 bits RSA)   FS
        # which have following names in OpenSSL (see `openssl ciphers`)

        %w[ECDHE-RSA-AES256-GCM-SHA384 ECDHE-RSA-AES128-GCM-SHA256]
      end
    end
  end
end
