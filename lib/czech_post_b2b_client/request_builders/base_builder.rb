# frozen_string_literal: true

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
    end
  end
end
