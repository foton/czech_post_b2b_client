# frozen_string_literal: true

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
        base_class = CzechPostB2bClient::PrintingTemplate::Base
        @allowed_printing_template_classes ||= ObjectSpace.each_object(base_class.singleton_class).to_a - [base_class]
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
        ox_element('serviceData') do |srv_data|
          srv_data << ox_element('ns2:getParcelsPrinting') do |get_parcels_printing|
            get_parcels_printing << do_printing_header
            get_parcels_printing << do_printing_data
          end
        end
      end

      def do_printing_header
        ox_element('ns2:doPrintingHeader') do |printing_header|
          printing_header << ox_element('ns2:customerID', value: options[:customer_id]) # Technologicke cislo podavatele
          printing_header << ox_element('ns2:contractNumber', value: options[:contract_number]) # Nepovine: ID CCK slozky podavatele
          printing_header << ox_element('ns2:idForm', value: options[:template_id]) # Nepovine[0-20x]: ID formulare
          printing_header << ox_element('ns2:shiftHorizontal', value: options[:margin_in_mm][:left]) # Hodnota posunu doprava v mm
          printing_header << ox_element('ns2:shiftVertical', value: options[:margin_in_mm][:top]) # Hodnota posunu dolu v mm
          printing_header << ox_element('ns2:position', value: options[:position_order]) # Nepovinna: Hodnota pozice
        end
      end

      def do_printing_data
        ox_element('ns2:doPrintingData') do |printing_data|
          parcel_codes.each do |parcel_code|
            printing_data << ox_element('ns2:parcelCode', value: parcel_code.to_s)
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
