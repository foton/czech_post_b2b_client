# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class SendParcelsParser < BaseParser
      def build_result
        super
        @result[:async_result] = { transaction_id: response_header.dig('idTransaction'),
                                   processing_end_expected_at: Time.parse(response_header.dig('timeStampProcessing')) } # it is NOT CORRECT! They return CET time value with UTC timezone
      end
    end
  end
end
