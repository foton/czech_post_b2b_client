# frozen_string_literal: true

# rubocop:disable Layout/LineLength

module CzechPostB2bClient
  module RequestBuilders
    class GetParcelsPrintingBuilder < BaseBuilder
      attr_reader :parcel_codes, :options

      def initialize(parcel_codes:, options:, request_id: 1)
        @parcel_codes = parcel_codes
        @options = options
        @request_id = request_id
      end

      def self.allowed_printing_template_classes
        @allowed_printing_template_classes ||= CzechPostB2bClient::PrintingTemplates.all_classes
      end

      private

      def validate_data
        if parcel_codes.empty?
          errors.add(:parcel_codes, 'Minimum of 1 parcel code is required!')
          fail!
        end

        if parcel_codes.size > 500
          errors.add(:parcel_codes, 'Maximum of 500 parcel codes are allowed!')
          fail!
        end

        validate_template_ids
      end

      def service_data_struct
        new_element('serviceData').tap do |srv_data|
          add_element_to(srv_data, get_parcels_printing)
        end
      end

      def get_parcels_printing # rubocop:disable Naming/AccessorMethodName
        new_element('ns2:getParcelsPrinting').tap do |get_parcels_printing|
          add_element_to(get_parcels_printing, do_printing_header)
          add_element_to(get_parcels_printing, do_printing_data)
        end
      end

      def do_printing_header # rubocop:disable Metrics/AbcSize
        new_element('ns2:doPrintingHeader').tap do |printing_header|
          add_element_to(printing_header, 'ns2:customerID', value: options[:customer_id]) # Technologicke cislo podavatele
          add_element_to(printing_header, 'ns2:contractNumber', value: options[:contract_number]) # Nepovine: ID CCK slozky podavatele
          add_element_to(printing_header, 'ns2:idForm', value: options[:template_id]) # Nepovine[0-20x]: ID formulare
          add_element_to(printing_header, 'ns2:shiftHorizontal', value: options[:margin_in_mm][:left]) # Hodnota posunu doprava v mm
          add_element_to(printing_header, 'ns2:shiftVertical', value: options[:margin_in_mm][:top]) # Hodnota posunu dolu v mm
          add_element_to(printing_header, 'ns2:position', value: options[:position_order]) # Nepovinna: Hodnota pozice
        end
      end

      def do_printing_data
        new_element('ns2:doPrintingData').tap do |printing_data|
          parcel_codes.each do |parcel_code|
            add_element_to(printing_data, 'ns2:parcelCode', value: parcel_code.to_s)
          end
        end
      end

      def validate_template_ids
        # TODO: there can be up to 20 `idForm` nodes, but I do not know how it works yet
        template_id = options[:template_id]
        return if template_id.to_s == ''

        allowed_ids = self.class.allowed_printing_template_classes.collect(&:id)
        return if allowed_ids.include?(template_id)

        errors.add(:template_id, "Value '#{template_id}' is not allowed!")
        fail!
      end
    end
  end
end

# rubocop:enable Layout/LineLength
