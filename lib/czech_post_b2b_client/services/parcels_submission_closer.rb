# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsSubmissionCloser < CzechPostB2bClient::Services::ParcelsAsyncSender
      attr_reader :sending_data

      def initialize(sending_data:)
        super(sending_data: sending_data, parcels: [])
      end

      private

      def request_builder_args
        { common_data: common_closing_data, parcels: [] }
      end

      def common_closing_data
        common_data.merge(close_requests_batch: true)
      end
    end
  end
end
