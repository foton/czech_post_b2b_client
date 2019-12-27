# frozen_string_literal: true
require 'ox'

module CzechPostB2bClient
  module RequestBuilders
    class BaseBuilder < SteppedService::Base
      attr_reader :request_id

      TIME_FORMAT = '%FT%T.%L%:z' # '2014-03-12T13:33:34.573+01:00'

      def initialize( request_id: 1)
        @request_id = request_id
      end

      def steps
        %i[build_xml_struct render_xml]
      end

      private

      attr_reader :xml_struct

      def build_xml_struct
        raise 'implement me'
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

      def ox_element(name, attributes: {}, value: nil, &block )
        ox_node(Ox::Element.new(name), {attributes: attributes, value: value}, &block)
      end

      def ox_instruct(attributes: {})
        ox_node(Ox::Instruct.new(:xml), {attributes: attributes})
      end

      def ox_node(node, args = {}, &block )
        (args[:attributes] || {}).each_pair { |key, val| node[key] = val }

        if block_given?
          yield(node)
        else
          node << args[:value].to_s  if args[:value].to_s != ''
        end

        node
      end
    end
  end
end
