# frozen_string_literal: true
require 'ox'

module CzechPostB2bClient
  module RequestBuilders
    class BaseBuilder
      TIME_FORMAT = '%FT%T.%L%:z' # '2014-03-12T13:33:34.573+01:00'

      def to_xml
        raise 'implement me'
      end

      private

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
