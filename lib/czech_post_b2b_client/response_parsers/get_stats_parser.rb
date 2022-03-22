# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class GetStatsParser < BaseParser
      def build_result
        super
        @result[:imports] = imports
      end

      def imports
        imports_hash = response_root_node
        { requested: imports_hash['importAll'].to_i,
          with_errors: imports_hash['importErr'].to_i,
          successful: imports_hash['importOk'].to_i,
          imported_parcels: imports_hash['parcels'].to_i }
      end

      def response_root_node_name
        'getStatsResponse'
      end
    end
  end
end
