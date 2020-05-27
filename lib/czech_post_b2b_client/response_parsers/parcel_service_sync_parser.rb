# frozen_string_literal: true

require 'base64'

module CzechPostB2bClient
  module ResponseParsers
    class ParcelServiceSyncParser < BaseParser
      def build_result
        super
        @result[:response][:state] = state_hash_from(response_state_response)
        @result[:parcel] = parcel_data_hash
      end

      def parcel_data_hash
        rp_hash = response_parcel_hash
        parcel_id = parcel_parcel_id_from(rp_hash)
        { parcel_id => parcel_data_from(rp_hash).merge(print: print_data_from(response_print_hash)) }
      end

      def response_root_node_name
        'parcelServiceSyncResponse'
      end

      def response_state_response
        response_root_node.dig('responseHeader', 'resultHeader')
      end

      def response_parcel_hash
        response_root_node.dig('responseHeader', 'resultParcelData')
      end

      def response_print_hash
        response_root_node.dig('responsePrintParams')
      end

      def parcel_parcel_id_from(rp_hash)
        rp_hash['recordNumber'].to_s
      end

      def parcel_data_from(rp_hash)
        { parcel_code: rp_hash['parcelCode'],
          states: [state_hash_from(rp_hash.dig('parcelDataResponse'))] }
      end

      def print_data_from(print_hash)
        return nil if print_hash.empty?

        { pdf_content: pdf_content_from(print_hash.dig('file')),
          state: state_hash_from(print_hash.dig('printParamsResponse')) }
      end

      def pdf_content_from(pdf_content_encoded)
        return nil if pdf_content_encoded.nil?

        ::Base64.decode64(pdf_content_encoded)
      end
    end
  end
end
