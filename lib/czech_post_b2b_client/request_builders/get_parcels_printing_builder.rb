# frozen_string_literal: true

module CzechPostB2bClient
  module RequestBuilders
    class GetParcelsPrintingBuilder < BaseBuilder
      attr_reader :parcel_codes, :options

      def initialize(parcel_codes: , options:, request_id: 1)
        @parcel_codes = parcel_codes
        @options = options
        @request_id = request_id
      end

      private

      def build_xml_struct
        @xml_struct = Ox::Document.new
        @xml_struct << ox_instruct(attributes: { version: '1.0', encoding: 'UTF-8', standalone: 'yes' })

        bb = ox_element('b2bRequest', attributes: configuration.namespaces) do |b2b_req|
          b2b_req << ox_element('header') do |header|
            header << ox_element('idExtTransaction', value: request_id)
            header << ox_element('timeStamp', value: Time.now.strftime(TIME_FORMAT))
            header << ox_element('idContract', value: configuration.contract_id)
          end

          b2b_req << ox_element('serviceData') do |srv_data|
            srv_data << ox_element('ns2:getParcelsPrinting') do |get_parcels_printing|
              get_parcels_printing << do_printing_header
              get_parcels_printing << do_printing_data
            end
          end
        end

        @xml_struct << bb

        @xml_struct
      end

      def do_printing_header
        ox_element('ns2:doPrintingHeader') do |printing_header|
          printing_header << ox_element('ns2:customerID', value: options[:customer_id]) # Technologicke cislo podavatele
          printing_header << ox_element('ns2:contractNumber', value: options[:contract_number]) # Nepoviné: ID CCK slozky podavatele
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
    end
  end
end
