# frozen_string_literal: true

require 'ox'

module CzechPostB2bClient
  module ResponseParsers
    class BaseParser < SteppedService::Base
      def initialize(response_xml, _other_to_fix)
        @response_xml = response_xml
      end

      def steps
        %i[parse_xml build_result]
      end

      private

      attr_accessor :response_xml, :response_hash

      def parse_xml
        @response_hash = Ox.load(response_xml,
                                 strip_namespace: true,
                                 symbolize_keys: false,
                                 mode: :hash_no_attrs)
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
        b2b_sync_response_hash.dig('serviceData')
      end

      def response_header
        b2b_sync_response_hash.dig('header')
      end

      def b2b_sync_response_hash
        response_hash.dig('b2bSyncResponse')
      end

      def request_data
        b2b_request_hash = response_header.dig('b2bRequestHeader')
        OpenStruct.new(id_ext_transaction: b2b_request_hash.dig('idExtTransaction').to_s,
                       time_stamp: Time.parse(b2b_request_hash.dig('timeStamp')),
                       id_contract: b2b_request_hash.dig('idContract').to_s)
      end
    end
  end
end
