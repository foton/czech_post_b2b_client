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
          '1' => { parcel_code: 'RA12354678', states: [{ code: 1, text: 'OK' }] },
          'second' => { parcel_code: 'RA12354679', states: [{ code: 1, text: 'OK' }] }
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
        @fake_response_parser_result[:response].merge!(state: { code: 1, text: 'OK' })
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

      def test_it_fails_with_errors_in_response_data # rubocop:disable  Metrics/AbcSize
        builder = successful_builder_mock
        api_caller = successful_api_caller_mock
        # parser just pass errors hash, but call/parsing is successful
        parser = parser_mock(expected_args: { xml: fake_api_caller_result.xml },
                             returns: fake_successful_service(parser_result_with_errors))

        builder_service_class.stub(:call, builder) do
          api_caller_service_class.stub(:call, api_caller) do
            parser_service_class.stub(:call, parser) do
              @service = tested_service_class.call(**tested_service_args)
            end
          end
        end
        assert_mock builder
        assert_mock api_caller
        assert_mock parser

        assert service.failure?
        assert_equal response_state_expected_errors, service.errors[:response_state]
        assert_equal expected_service_errors_on_parcels, service.errors[:parcels]
        assert_equal expected_result_parcels_hash_with_errors, service.result.parcels_hash
      end

      def expected_result_parcels_hash_with_errors
        {
          '1' => { parcel_code: 'RA12354678', states: [{ code: 1, text: 'OK' }] },
          'second' => { parcel_code: nil, states: [{ code: 104, text: 'INVALID_WEIGHT' },
                                                   { code: 261, text: 'MISSING_SIZE_CATEGORY' }] },
          'parcel_3' => { parcel_code: nil, states: [{ code: 310, text: 'INVALID_PREFIX' }] }
        }
      end

      def parser_result_with_errors
        parser_result_with_errors = fake_response_parser_result_shared_part
        parser_result_with_errors.merge!(parcels: expected_result_parcels_hash_with_errors)
        parser_result_with_errors[:response].merge!(state: { code: 19, text: 'BATCH_INVALID' })
        parser_result_with_errors
      end

      def response_state_expected_errors
        [CzechPostB2bClient::ResponseCodes.new_by_code(19).to_s]
      end

      def expected_service_errors_on_parcels
        ["Parcel[second] => #{CzechPostB2bClient::ResponseCodes.new_by_code(104)}",
         "Parcel[second] => #{CzechPostB2bClient::ResponseCodes.new_by_code(261)}",
         "Parcel[parcel_3] => #{CzechPostB2bClient::ResponseCodes.new_by_code(310)}"]
      end
    end
  end
end
