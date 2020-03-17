# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class GetResultParcelsParser < BaseParser
      def build_result
        super
        @result[:response][:state] = state_hash_from(response_state_response)
        @result[:parcels] = parcels_data_hash
      end

      def parcels_data_hash
        response_parcel_hashes.each_with_object({}) do |rp_hash, result|
          parcel_id = parcel_parcel_id_from(rp_hash)
          result[parcel_id] = updated_result_value_for(result[parcel_id], rp_hash)
        end
      end

      def response_state_response
        response_service_data.dig('getResultParcelsResponse').dig('doParcelHeaderResult').dig('doParcelStateResponse')
      end

      def response_parcel_hashes
        [response_service_data.dig('getResultParcelsResponse').dig('doParcelParamResult')].flatten.compact # to always get array of hash(es)
      end

      def parcel_parcel_id_from(rp_hash)
        rp_hash['recordNumber'].to_s
      end

      def parcel_data_from(rp_hash)
        { parcel_code: rp_hash['parcelCode'],
          states: [state_hash_from(rp_hash.dig('doParcelStateResponse'))] }
      end

      def updated_result_value_for(value, parcel_params_result_hash)
        pd_hash=parcel_data_from(parcel_params_result_hash)

        return pd_hash if value.nil?

        # more doParcelParamsResult nodes for one parcel_id => probably errors
        old_p_code = value[:parcel_code]
        new_p_code = pd_hash[:parcel_code]

        value[:states] = (value[:states] + pd_hash[:states]).sort { |a, b| a[:code] <=> b[:code] }
        raise "Two different parcel_codes [#{old_p_code}, #{new_p_code}] for parcel_id:'#{parcel_id}'" if old_p_code != new_p_code

        value
      end
    end
  end
end
