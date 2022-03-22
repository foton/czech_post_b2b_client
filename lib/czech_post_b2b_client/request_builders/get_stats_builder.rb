# frozen_string_literal: true

module CzechPostB2bClient
  module RequestBuilders
    class GetStatsBuilder < BaseBuilder
      attr_reader :from_date, :to_date

      def initialize(from_date:, to_date:, request_id: 1)
        super()
        @from_date = from_date.to_time
        @to_date = to_date.to_time
        @request_id = request_id
      end

      private

      def service_data_struct
        new_element('serviceData').tap do |srv_data|
          add_element_to(srv_data, get_stats)
        end
      end

      def get_stats # rubocop:disable Naming/AccessorMethodName
        new_element('ns2:getStats').tap do |get_stats|
          add_element_to(get_stats, 'ns2:dateBegin', value: from_date.strftime(TIME_FORMAT))
          add_element_to(get_stats, 'ns2:dateEnd', value: to_date.strftime(TIME_FORMAT))
        end
      end
    end
  end
end
