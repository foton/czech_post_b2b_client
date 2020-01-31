# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsSendProcessUpdater < CzechPostB2bClient::Services::Communicator
      attr_reader :transaction_id

      def initialize(transaction_id:)
        @transaction_id = transaction_id
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
        OpenStruct.new(parcels_hash: response_hash[:parcels])
      end
    end
  end
end
