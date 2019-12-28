# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class GetStatsParser < BaseParser
      def build_result
        super
        @result[:imports] = { requested: imports.all,
                              with_errors: imports.err,
                              sucessfull: imports.ok,
                              imported_parcels: imports.parcels }
      end

      def imports
        imports_hash = response_service_data.dig('getStatsResponse')
        OpenStruct.new(all: imports_hash.dig('importAll').to_i,
                       err: imports_hash.dig('importErr').to_i,
                       ok: imports_hash.dig('importOk').to_i,
                       parcels: imports_hash.dig('parcels').to_i)
      end
    end
  end
end
