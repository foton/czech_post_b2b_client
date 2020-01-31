# frozen_string_literal: true

require 'ox'

module CzechPostB2bClient
  module ResponseParsers
    class BaseParser < SteppedService::Base
      def initialize(xml:)
        @response_xml = xml
      end

      def steps
        %i[parse_xml safely_build_result]
      end

      private

      attr_accessor :response_xml, :response_hash

      def parse_xml
        @response_hash = Ox.load(response_xml,
                                 strip_namespace: true,
                                 symbolize_keys: false,
                                 mode: :hash_no_attrs)
      rescue Ox::ParseError => error
        handle_parsing_error(error)
      end

      def safely_build_result
        build_result
      rescue NoMethodError => error # NoMethodError: undefined method `dig' for nil:NilClass
        handle_result_building_error(error)
      end

      def build_result
        @result = {
          request: { created_at: request_data.time_stamp,
                     contract_id: request_data.id_contract,
                     request_id: request_data.id_ext_transaction },
          response: { created_at: Time.parse(response_header.dig('timeStamp')) }
        }
      end

      def response_service_data
        b2b_response_hash.dig('serviceData')
      end

      def response_header
        b2b_response_hash.dig('header')
      end

      def b2b_response_hash
        response_hash.dig('b2bSyncResponse') || response_hash.dig('b2bASyncResponse')
      end

      def request_data
        b2b_request_hash = response_header.dig('b2bRequestHeader')
        OpenStruct.new(id_ext_transaction: b2b_request_hash.dig('idExtTransaction').to_s,
                       time_stamp: Time.parse(b2b_request_hash.dig('timeStamp')),
                       id_contract: b2b_request_hash.dig('idContract').to_s)
      end

      def handle_parsing_error(error)
        @result = { parser_error: error.message, xml: response_xml }
        errors.add(:xml, "XML can not be parsed! Is it valid XML? #{error.class} > #{error.message}")
        fail!
      end

      def handle_result_building_error(error)
        @result = { result_builder_error: error.message + ' at line: ' + error.backtrace.first,
                    response_hash: response_hash }
        errors.add(:xml, 'Parsed XML can not be converted to result hash. Is it correct response for this parser?')
        fail!
      end
    end
  end
end
