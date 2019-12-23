# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class GetStatsParser < BaseParser
      def initialize(response_xml, _other_to_fix)
        @response_xml = response_xml
      end

      def steps
        %i[parse_xml build_result]
      end

      private

      attr_accessor :response_xml, :response_hash

      def parse_xml
        @response_hash = Ox.load(response_xml, mode: :hash_no_attrs)
      end

      def build_result
        @result = {
          imports: { requested: imports.all,
                     with_errors: imports.err,
                     sucessfull: imports.ok,
                     imported_parcels: imports.parcels },
          request: { created_at: request_data.time_stamp,
                     contract_id: request_data.id_contract,
                     request_id: request_data.id_ext_transaction },
          response: { created_at: Time.parse(response_header.dig(:'v1:timeStamp')) }
        }
      end

      def imports
        imports_hash = response_service_data.dig(:'v1_1:getStatsResponse')
        OpenStruct.new(all: imports_hash.dig(:'v1_1:importAll').to_i,
                       err: imports_hash.dig(:'v1_1:importErr').to_i,
                       ok: imports_hash.dig(:'v1_1:importOk').to_i,
                       parcels: imports_hash.dig(:'v1_1:parcels').to_i)
      end

      def request_data
        b2b_request_hash = response_header.dig(:'v1:b2bRequestHeader')
        OpenStruct.new(id_ext_transaction: b2b_request_hash.dig(:'v1:idExtTransaction').to_s,
                       time_stamp: Time.parse(b2b_request_hash.dig(:'v1:timeStamp')),
                       id_contract: b2b_request_hash.dig(:'v1:idContract').to_s)
      end

      def response_service_data
        b2b_sync_response_hash.dig(:'v1:serviceData')
      end

      def response_header
        b2b_sync_response_hash.dig(:'v1:header')
      end

      def b2b_sync_response_hash
        response_hash.dig(:'v1:b2bSyncResponse')
      end
    end
  end
end
