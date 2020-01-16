# frozen_string_literal: true

module CzechPostB2bClient
  module RequestBuilders
    class GetParcelStateBuilder < BaseBuilder
      attr_reader :parcel_codes

      def initialize(parcel_codes:, request_id: 1)
        @parcel_codes = parcel_codes
        @request_id = request_id
      end

      private

      def validate_data
        if parcel_codes.empty?
          errors.add(:parcel_codes, 'Minimum of 1 parcel code is required!')
          fail!
        end

        return if parcel_codes.size <= 10

        errors.add(:parcel_codes, 'Maximum of 10 parcel codes are allowed!')
        fail!
      end

      def service_data_struct
        ox_element('serviceData') do |srv_data|
          srv_data << get_parcel_state
        end
      end

      def get_parcel_state # rubocop:disable Naming/AccessorMethodName
        ox_element('ns2:getParcelState') do |parcel_state|
          parcel_codes.each do |parcel_code|
            parcel_state << ox_element('ns2:idParcel', value: parcel_code.to_s)
          end

          parcel_state << ox_element('ns2:language', value: configuration.language.to_s)
        end
      end
    end
  end
end
