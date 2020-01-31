# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class GetResultParcelsParser < BaseParser
      def build_result
        super
        @result[:parcels] = parcels_data_hash
      end

      def parcels_data_hash
        response_parcel_hashes.each_with_object({}) do |rp_hash, result|
          result[parcel_record_id_from(rp_hash)] = parcel_data_from(rp_hash)
        end
      end

      def response_parcel_hashes
        response_service_data.dig('getResultParcelsResponse').dig('doParcelParamResult')
      end

      def parcel_record_id_from(rp_hash)
        rp_hash['recordNumber'].to_s
      end

      def parcel_data_from(rp_hash)
        state_hash = rp_hash['doParcelStateResponse'] || { 'responseCode' => '999', 'responseText' => 'Unknown' }
        state_hash = state_hash.first if state_hash.is_a?(Array) # more <doParcelStateResponse> elements
        {
          parcel_code: rp_hash['parcelCode'],
          state_code: state_hash['responseCode'].to_i,
          state_text: state_hash['responseText'].to_s,
        }
      end
    end
  end
end
