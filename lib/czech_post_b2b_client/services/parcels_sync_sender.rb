# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    # Combination of ParcelsAsyncSender + ParcelsSendProcessUpdater for fast SYNC registering parcel at CPOST
    # It accept only one parcel!
    # It should be used for instant one parcel registration.
    class ParcelsSyncSender < CzechPostB2bClient::Services::Communicator
      attr_reader :sending_data, :parcels

      def initialize(sending_data:, parcels:)
        @sending_data = sending_data
        @parcels = parcels
      end

      def steps
        super + %i[check_for_state_errors]
      end

      private

      def request_builder_args
        { common_data: common_data, parcel: parcels.first }
      end

      def request_builder_class
        CzechPostB2bClient::RequestBuilders::ParcelServiceSyncBuilder
      end

      def api_caller_class
        CzechPostB2bClient::Services::ApiCaller
      end

      def response_parser_class
        CzechPostB2bClient::ResponseParsers::ParcelServiceSyncParser
      end

      def common_data
        data_from_config.merge(sending_data)
      end

      def data_from_config
        {
          contract_id: configuration.contract_id,
          customer_id: configuration.customer_id,
          sending_post_office_code: configuration.sending_post_office_code
        }
      end

      def endpoint_path
        '/parcelServiceSync'
      end

      def build_result_from(response_hash)
        OpenStruct.new(parcels_hash: response_hash[:parcel],
                       state_text: response_hash.dig(:response, :state, :text),
                       state_code: response_hash.dig(:response, :state, :code))
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
          add_errors_for_failed_states(parcel_id, parcel_hash[:states])
        end
      end

      def add_errors_for_failed_states(parcel_id, response_states)
        response_states.each do |response_state|
          response_code = response_state[:code]
          next if response_code == CzechPostB2bClient::ResponseCodes::Ok.code

          errors.add(:parcels, "Parcel[#{parcel_id}] => #{CzechPostB2bClient::ResponseCodes.new_by_code(response_code)}") # rubocop:disable Layout/LineLength
        end
      end
    end
  end
end
