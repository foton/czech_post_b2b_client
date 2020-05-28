# frozen_string_literal: true

require 'openssl'
require 'net/http'

module CzechPostB2bClient
  module Services
    class XsdsDownloader < ApiCaller
      def initialize(_anything); end

      def steps
        %i[download_xsds]
      end

      private

      attr_reader :xsd_uri

      def download_xsds
        xsd_uris = configuration.namespaces.values
        xsd_uris.each do |uri|
          # check for  `.xsd` at end?
          @xsd_uri = URI.parse(uri)
          download
        end
      end

      def download # rubocop:disable Metrics/AbcSize
        self.response = https_conn.request(request)

        debug_msg = "CzechPost XSD REQUEST: #{request} to #{xsd_uri} with body:\n#{request.body} => #{response.code}"
        CzechPostB2bClient.logger.debug(debug_msg)

        raise "Error in downloading #{xsd_uri} => #{response}" unless response.code.to_i == 200

        save_response_to_file
      rescue *KNOWN_CONNECTION_ERRORS => e
        raise "Error in downloading #{xsd_uri} => #{e.message}"
      end

      def https_conn
        Net::HTTP.start(xsd_uri.host, xsd_uri.port, connection_options)
      end

      def request
        Net::HTTP::Get.new xsd_uri.request_uri, headers
      end

      def save_response_to_file
        filename = xsd_uri.request_uri.split('/').last
        filename += '.xsd' if filename.split('.').last.downcase != 'xsd'

        File.write(filename, response.body)
      end

      def headers
        {}
      end
    end
  end
end
