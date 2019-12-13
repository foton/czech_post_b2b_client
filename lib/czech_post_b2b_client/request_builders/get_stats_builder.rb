# frozen_string_literal: true

module CzechPostB2bClient
  module RequestBuilders
    class GetStatsBuilder < BaseBuilder
      def initialize(from_date:, to_date:)
        @from_date = from_date.to_time
        @to_date = to_date.to_time
      end

      def to_xml
        doc = Ox::Document.new
        doc << instruct
        doc << b2b_request

        Ox.dump(doc)
      end

      private

      attr_reader :from_date, :to_date

      def instruct
        instruct = Ox::Instruct.new(:xml)
        instruct[:version] = '1.0'
        instruct[:encoding] = 'UTF-8'
        instruct[:standalone] = 'yes'
        instruct
      end

      def b2b_request
        b2b_request = Ox::Element.new('b2bRequest')
        configuration.namespaces.each_pair { |ns, url| b2b_request[ns] = url }

        b2b_request << header
        b2b_request << service_data

        b2b_request
      end

      def header
        header = Ox::Element.new('header')

        id_ext_transaction = Ox::Element.new('idExtTransaction')
        id_ext_transaction << 1.to_s

        time_stamp = Ox::Element.new('timeStamp')
        time_stamp << Time.now.strftime(TIME_FORMAT)

        id_contract = Ox::Element.new('idContract')
        id_contract << configuration.contract_id

        header << id_ext_transaction
        header << time_stamp
        header << id_contract

        header
      end


      def service_data
        service_data = Ox::Element.new('serviceData')

        get_stats = Ox::Element.new('ns2:getStats')

        date_begin = Ox::Element.new('ns2:dateBegin')
        date_begin << from_date.strftime(TIME_FORMAT)

        date_end = Ox::Element.new('ns2:dateEnd')
        date_end << to_date.strftime(TIME_FORMAT)

        get_stats << date_begin
        get_stats << date_end
        service_data << get_stats

        service_data
      end
    end
  end
end
