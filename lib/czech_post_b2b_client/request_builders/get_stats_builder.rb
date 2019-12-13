# frozen_string_literal: true

module CzechPostB2bClient
  module RequestBuilders
    class GetStatsBuilder < BaseBuilder
      def initialize(from_date:, to_date:)
        @from_date = from_date.to_time
        @to_date = to_date.to_time
      end

      def to_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <b2bRequest #{namespaces}>
            <header>
              <idExtTransaction>1</idExtTransaction>
              <timeStamp>#{Time.now.strftime(TIME_FORMAT)}</timeStamp>
              <idContract>#{configuration.contract_id}</idContract>
            </header>
            <serviceData>
              <ns2:getStats>
                <ns2:dateBegin>#{from_date.strftime(TIME_FORMAT)}</ns2:dateBegin>
                <ns2:dateEnd>#{to_date.strftime(TIME_FORMAT)}</ns2:dateEnd>
              </ns2:getStats>
            </serviceData>
          </b2bRequest>
        XML
      end

      private

      attr_reader :from_date, :to_date
    end
  end
end
