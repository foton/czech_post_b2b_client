# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsSendProcessUpdater < CzechPostB2bClient::Services::Communicator
      attr_reader :transaction_id

      def initialize(transaction_id:)
        @transaction_id = transaction_id
      end

      def steps
        super + %i[check_for_state_errors]
      end

      private

      def request_builder_args
        { transaction_id: transaction_id }
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder
      end

      def api_caller_class
        CzechPostB2bClient::Services::ApiCaller
      end

      def response_parser_class
        CzechPostB2bClient::ResponseParsers::GetResultParcelsParser
      end

      def endpoint_path
        '/getResultParcels'
      end

      def build_result_from(response_hash)
        OpenStruct.new(parcels_hash: response_hash[:parcels],
                       state_text: response_hash.dig(:response, :state_text),
                       state_code: response_hash.dig(:response, :state_code))
      end

      def check_for_state_errors
        return if result.state_code == CzechPostB2bClient::ResponseCodes::Ok.code

        r_code = CzechPostB2bClient::ResponseCodes.new_by_code(result.state_code)
        errors.add(:response_state, r_code.to_s)

        collect_parcel_errors

        fail! unless r_code.info?
      end

      def collect_parcel_errors
        result.parcels_hash.each_pair do |parcel_id, parcel_hash|
          next if parcel_hash[:state_code] == CzechPostB2bClient::ResponseCodes::Ok.code

          errors.add(:parcels, "Parcel[#{parcel_id}] => #{CzechPostB2bClient::ResponseCodes.new_by_code(parcel_hash[:state_code])}")
        end
      end
    end
  end
end
