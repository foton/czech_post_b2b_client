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
        parcel_id = nil
        pdh = response_parcel_hashes.each_with_object({}) do |rp_hash, result|
          parcel_id = parcel_parcel_id_from(rp_hash)
          result[parcel_id] = updated_result_value_for(result[parcel_id], rp_hash)
        end
        pdh[parcel_id].merge!(printings: print_data_from(response_print_hash))

        pdh
      end

      def response_root_node_name
        'parcelServiceSyncResponse'
      end

      def response_state_response
        response_root_node.dig('responseHeader', 'resultHeader')
      end

      def response_parcel_hashes
        [response_root_node.dig('responseHeader', 'resultParcelData')].flatten.compact # to always get array of hash(es)
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
        return nil if print_hash.nil? || print_hash.empty?

        { pdf_content: pdf_content_from(print_hash.dig('file')),
          state: state_hash_from(print_hash.dig('printParamsResponse')) }
      end

      def pdf_content_from(pdf_content_encoded)
        return nil if pdf_content_encoded.nil?

        ::Base64.decode64(pdf_content_encoded)
      end

      def updated_result_value_for(value, parcel_params_result_hash)
        pd_hash = parcel_data_from(parcel_params_result_hash)

        return pd_hash if value.nil?

        # merging states
        value[:states] = (value[:states] + pd_hash[:states]).sort { |a, b| a[:code] <=> b[:code] }

        # more parcel_codes for one parcel_id => probably errors
        old_p_code = value[:parcel_code]
        new_p_code = pd_hash[:parcel_code]
        if old_p_code != new_p_code
          raise "Two different parcel_codes [#{old_p_code}, #{new_p_code}] for parcel_id:'#{parcel_id}'"
        end

        value
      end
    end
  end
end
