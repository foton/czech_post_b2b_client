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
        @xml_struct = Ox::Document.new
        @xml_struct << ox_instruct(attributes: { version: '1.0', encoding: 'UTF-8', standalone: 'yes' })

        bb = ox_element('b2bRequest', attributes: configuration.namespaces) do |b2b_req|
          b2b_req << b2b_req_header
          b2b_req << service_data_struct
        end

        @xml_struct << bb

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

      def b2b_req_header
        ox_element('header') do |header|
          header << ox_element('idExtTransaction', value: request_id)
          header << ox_element('timeStamp', value: Time.now.strftime(TIME_FORMAT))
          header << ox_element('idContract', value: configuration.contract_id)
        end
      end

      def ox_element(name, attributes: {}, value: nil, &block)
        ox_node(Ox::Element.new(name), { attributes: attributes, value: value }, &block)
      end

      def ox_instruct(attributes: {})
        ox_node(Ox::Instruct.new(:xml), attributes: attributes)
      end

      def ox_node(node, args = {})
        (args[:attributes] || {}).each_pair { |key, val| node[key] = val }

        if block_given?
          yield(node)
        elsif args[:value].to_s != ''
          node << args[:value].to_s
        end

        node
      end
    end
  end
end
