# frozen_string_literal: true

require 'base64'

module CzechPostB2bClient
  module ResponseParsers
    class GetParcelsPrintingParser < BaseParser
      def build_result
        super
        @result[:response][:state] = state_hash_from(printing_response_header_result['doPrintingStateResponse'])
        @result[:printings] = { options: options_hash,
                                pdf_content: pdf_content }
      end

      def options_hash
        options_response = printing_response_header_result['doPrintingHeader']
        {
          customer_id: options_response['customerID'],
          contract_number: options_response['contractNumber'],
          template_id: options_response['idForm'].to_i,
          margin_in_mm: { top: options_response['shiftVertical'].to_i,
                          left: options_response['shiftHorizontal'].to_i },
          position_order: options_response['position'].to_i
        }
      end

      def pdf_content
        pdf_content_encoded = response_root_node.dig('doPrintingDataResult', 'file')
        return nil if pdf_content_encoded.nil?

        ::Base64.decode64(pdf_content_encoded)
      end

      def response_root_node_name
        'getParcelsPrintingResponse'
      end

      def printing_response_header_result
        response_root_node['doPrintingHeaderResult']
      end
    end
  end
end
