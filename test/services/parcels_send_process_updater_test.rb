# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class ParcelsSendProcessUpdaterTest < Minitest::Test
      include CzechPostB2bClient::Test::CommunicatorServiceTestingBase

      attr_reader :transaction_id, :expected_parcels_hash

      def setup
        setup_configuration

        @transaction_id = 'transaction1'
        @expected_parcels_hash = {
          '1' => { parcel_code: 'RA12354678', state_code: 1, state_text: 'OK' },
          'second' => { parcel_code: 'RA12354679', state_code: 1, state_text: 'OK' }
        }
        @endpoint_path = '/getResultParcels' # 'https://b2b.postaonline.cz/services/POLService/v1/getResultParcels'

        @tested_service_class = CzechPostB2bClient::Services::ParcelsSendProcessUpdater
        @tested_service_args = { transaction_id: @transaction_id }

        @builder_service_class = CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder
        @parser_service_class = CzechPostB2bClient::ResponseParsers::GetResultParcelsParser
        @builder_expected_args = { transaction_id: transaction_id }
        @builder_expected_errors = { parcels: ['Too many'],
                                     common_data: ['Missing :parcels_sending_date value', 'xxx'] }
        @fake_response_parser_result = fake_response_parser_result_shared_part.merge(parcels: @expected_parcels_hash)
      end

      def builder_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |transaction_id:|
          transaction_id == expected_args[:transaction_id]
        end
        fake
      end

      def succesful_call_asserts(tested_service)
        assert_equal @expected_parcels_hash, tested_service.result.parcels_hash
      end
    end
  end
end
