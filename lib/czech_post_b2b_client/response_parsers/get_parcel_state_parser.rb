# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class GetParcelStateParser < BaseParser
      def build_result
        super
        @result[:parcels] = parcels_data_hash
      end

      def parcels_data_hash
        response_parcel_hashes.each_with_object({}) do |rp_hash, result|
          result[rp_hash['idParcel']] = parcel_data_from(rp_hash)
        end
      end

      def response_parcel_hashes
        response_service_data.dig('getParcelStateResponse').dig('parcel')
      end

      def parcel_data_from(rp_hash)
        {
          parcel_type: rp_hash['parcelType'].to_s,
          weight_in_kg: rp_hash['weight'].nil? ? nil : rp_hash['weight'].to_f,  # hopefully it is in KG
          cash_on_delivery_amount: (rp_hash['amount'] || 0).to_f,
          cash_on_delivery_currency: rp_hash['currency'].to_s,
          pieces: (rp_hash['quantityParcel'] || 1).to_i,
          deposited_until: rp_hash['depositTo'].nil? ? nil : Date.parse(rp_hash['depositTo']),
          deposited_for_days: rp_hash['timeDeposit'].nil? ? nil : rp_hash['timeDeposit'].to_i,
          country_of_origin: rp_hash['countryOfOrigin'].to_s,
          country_of_destination: rp_hash['countryOfDestination'].to_s,
          states: states_array_from(rp_hash)
        }
      end

      def states_array_from(rp_hash)
        rp_states = rp_hash.dig('states').dig('state')
        return [] if rp_states.nil?

        rp_states.collect do |rp_state_hash|
          { id: rp_state_hash['id'].to_s,
            date: Date.parse(rp_state_hash['date']),
            text: rp_state_hash['text'],
            post_code: rp_state_hash['postCode'],
            post_name: rp_state_hash['name'] }
        end
      end
    end
  end
end
