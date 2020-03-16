# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class GetResultParcelsParser < BaseParser
      def build_result
        super
        @result[:response].merge!(state_hash_from(response_state_response))
        @result[:parcels] = parcels_data_hash
      end

      def parcels_data_hash
        response_parcel_hashes.each_with_object({}) do |rp_hash, result|
          result[parcel_parcel_id_from(rp_hash)] = parcel_data_from(rp_hash)
        end
      end

      def response_state_response
        response_service_data.dig('getResultParcelsResponse').dig('doParcelHeaderResult').dig('doParcelStateResponse')
      end

      def response_parcel_hashes
        response_service_data.dig('getResultParcelsResponse').dig('doParcelParamResult')
      end

      def parcel_parcel_id_from(rp_hash)
        rp_hash['recordNumber'].to_s
      end

      def parcel_data_from(rp_hash)
        state_hash_from(rp_hash.dig('doParcelStateResponse')).merge({ parcel_code: rp_hash['parcelCode'] })
      end
    end
  end
end
