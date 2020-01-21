# frozen_string_literal: true

require 'ox'

module CzechPostB2bClient
  module RequestBuilders
    class BaseBuilder < SteppedService::Base
      attr_reader :request_id

      TIME_FORMAT = '%FT%T.%L%:z' # '2014-03-12T13:33:34.573+01:00'

      def initialize(request_id: 1)
        @request_id = request_id
      end

      def steps
        %i[validate_data
           build_xml_struct
           render_xml]
      end

      private

      attr_reader :xml_struct

      def validate_data
        # nothing to validate
      end

      def build_xml_struct
        @xml_struct = struct_base
        add_element_to(@xml_struct, new_instruct(attributes: { version: '1.0', encoding: 'UTF-8', standalone: 'yes' }))

        bb = new_element('b2bRequest', attributes: configuration.namespaces).tap do |b2b_req|
          add_element_to(b2b_req, b2b_req_header)
          add_element_to(b2b_req, service_data_struct)
        end

        add_element_to(@xml_struct, bb)

        @xml_struct
      end

      def render_xml
        @result = Ox.dump(xml_struct)
      end

      def configuration
        CzechPostB2bClient.configuration
      end

      def namespaces
        configuration.namespaces.to_a.collect { |ns, url| "#{ns}=\"#{url}\"" }.join(' ')
      end

      def struct_base
        Ox::Document.new(encoding: 'utf-8')
      end

      def b2b_req_header
        new_element('header').tap do |header|
          add_element_to(header, 'idExtTransaction', value: request_id)
          add_element_to(header, 'timeStamp', value: Time.now.strftime(TIME_FORMAT))
          add_element_to(header, 'idContract', value: configuration.contract_id)
        end
      end

      def add_element_to(parent_element, element, attributes: {}, value: nil)
        if element.is_a?(String)
          parent_element << new_element(element, attributes: attributes, value: value) unless value.nil?
        else
          parent_element << element unless element.nil?
        end
      end

      def new_element(name, attributes: {}, value: '')
        Ox::Element.new(name).tap do |elm|
          attributes.each_pair { |key, val| elm[key] = val }
          elm << value.to_s
        end
      end

      def new_instruct(attributes: {})
        Ox::Instruct.new(:xml).tap do |elm|
          attributes.each_pair { |key, val| elm[key] = val }
        end
      end
    end
  end
end
