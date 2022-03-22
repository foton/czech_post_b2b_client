# frozen_string_literal: true

require 'ox'

module CzechPostB2bClient
  module ResponseParsers
    class BaseParser < SteppedService::Base
      def initialize(xml:)
        super()
        @response_xml = xml
      end

      def steps
        %i[parse_xml safely_build_result]
      end

      private

      attr_accessor :response_xml, :response_hash

      def parse_xml
        @response_hash = Ox.load(response_xml,
                                 strip_namespace: true,
                                 symbolize_keys: false,
                                 mode: :hash_no_attrs)
      rescue Ox::ParseError => e
        handle_parsing_error(e)
      end

      def safely_build_result
        build_result
      rescue NoMethodError => e # NoMethodError: undefined method `dig' for nil:NilClass
        handle_result_building_error(e)
      end

      def build_result
        @result = {
          request: { created_at: request_data.time_stamp,
                     contract_id: request_data.id_contract,
                     request_id: request_data.id_ext_transaction },
          response: { created_at: response_time }
        }
      end

      def response_service_data
        b2b_response_hash['serviceData']
      end

      def response_header
        b2b_response_hash['header']
      end

      def response_root_node
        return response_service_data[response_root_node_name] if response_service_data.keys.include?(response_root_node_name)

        errors.add(:xml, "Cannot find `#{response_root_node_name}` in `serviceData` node.")
        fail_on_structure_parsing
      end

      def b2b_response_hash
        response_hash['b2bSyncResponse'] || response_hash['b2bASyncResponse']
      end

      def request_data
        b2b_request_hash = response_header['b2bRequestHeader']
        OpenStruct.new(id_ext_transaction: b2b_request_hash['idExtTransaction'].to_s,
                       time_stamp: Time.parse(b2b_request_hash['timeStamp']),
                       id_contract: b2b_request_hash['idContract'].to_s)
      end

      def response_time
        Time.parse(response_header['timeStamp'])
      rescue TypeError
        Time.now.utc
      end

      def state_hash_from(hash)
        state_hash = hash || { 'responseCode' => '999', 'responseText' => 'Unknown' }
        state_hash = state_hash.first if state_hash.is_a?(Array) # more <doParcelStateResponse> elements

        { code: state_hash['responseCode'].to_i, text: state_hash['responseText'].to_s }
      end

      def handle_parsing_error(error)
        @result = { parser_error: error.message, xml: response_xml }
        errors.add(:xml, "XML can not be parsed! Is it valid XML? #{error.class} > #{error.message}")
        fail!
      end

      def handle_result_building_error(error)
        @result = { result_builder_error: "#{error.message} at line: #{error.backtrace.first}",
                    response_hash: response_hash }
        fail_on_structure_parsing
      end

      def fail_on_structure_parsing
        errors.add(:xml, 'Parsed XML can not be converted to result hash. Is it correct response for this parser?')
        fail!
      end
    end
  end
end
