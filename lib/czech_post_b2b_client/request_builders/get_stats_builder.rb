# frozen_string_literal: true

module CzechPostB2bClient
  module RequestBuilders
    class GetStatsBuilder < BaseBuilder
      attr_reader :from_date, :to_date

      def initialize(from_date:, to_date:, request_id: 1)
        @from_date = from_date.to_time
        @to_date = to_date.to_time
        @request_id = request_id
      end

      private

      def service_data_struct
        ox_element('serviceData') do |srv_data|
          srv_data << ox_element('ns2:getStats') do |get_stats|
            get_stats << ox_element('ns2:dateBegin', value: from_date.strftime(TIME_FORMAT))
            get_stats << ox_element('ns2:dateEnd', value: to_date.strftime(TIME_FORMAT))
          end
        end
      end
    end
  end
end
