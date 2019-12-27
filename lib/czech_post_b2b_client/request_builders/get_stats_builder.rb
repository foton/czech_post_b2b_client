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

      def build_xml_struct
        @xml_struct = Ox::Document.new
        @xml_struct << ox_instruct(attributes: { version: '1.0', encoding: 'UTF-8', standalone: 'yes' })

        bb = ox_element('b2bRequest', attributes: configuration.namespaces) do |b2b_req|
          b2b_req << ox_element('header') do |header|
            header << ox_element('idExtTransaction', value: request_id)
            header << ox_element('timeStamp', value: Time.now.strftime(TIME_FORMAT))
            header << ox_element('idContract', value: configuration.contract_id)
          end

          b2b_req << ox_element('serviceData') do |srv_data|
            srv_data << ox_element('ns2:getStats') do |get_stats|
              get_stats << ox_element('ns2:dateBegin', value: from_date.strftime(TIME_FORMAT))
              get_stats << ox_element('ns2:dateEnd', value: to_date.strftime(TIME_FORMAT))
            end
          end
        end

        @xml_struct << bb

        @xml_struct
      end
    end
  end
end
