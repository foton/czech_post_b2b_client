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
        @fake_response_parser_result = fake_response_parser_result_shared_part.merge(parcels: @expected_parcels_hash,
                                                                                     response: { state_code: 1, state_text: 'OK'})
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

      def test_it_fails_with_errors_in_response_data
        expected_parcels_hash_with_errors = {
          '1' => { parcel_code: 'RA12354678', state_code: 1, state_text: 'OK' },
          'second' => { parcel_code: 'RA12354679', state_code: 261, state_text: 'MISSING_SIZE_CATEGORY' },
          'parcel_3' => { parcel_code: 'RA12354679', state_code: 104, state_text: 'INVALID_WEIGHT' }
        }
        fake_response_parser_result_with_errors = fake_response_parser_result_shared_part.merge(parcels: expected_parcels_hash_with_errors)
        fake_response_parser_result_with_errors[:response].merge!({ state_code: 19, state_text: 'BATCH_INVALID'})

        response_state_expected_errors = [CzechPostB2bClient::ResponseCodes::new_by_code(19).to_s]
        parcels_errors = ["Parcel[second] => #{CzechPostB2bClient::ResponseCodes::new_by_code(261).to_s}",
                          "Parcel[parcel_3] => #{CzechPostB2bClient::ResponseCodes::new_by_code(104).to_s}"]

        builder = builder_mock(expected_args: builder_expected_args,
                               returns: fake_successful_service(fake_request_builder_result))
        api_caller = api_caller_mock(expected_args: { endpoint_path: endpoint_path, xml: fake_request_builder_result },
                                     returns: fake_successful_service(fake_api_caller_result))
        # parser just pass errors hash, but call/parsing is successful
        parser = parser_mock(expected_args: { xml: fake_api_caller_result.xml },
                             returns: fake_successful_service(fake_response_parser_result_with_errors))

        builder_service_class.stub(:call, builder) do
          api_caller_service_class.stub(:call, api_caller) do
            parser_service_class.stub(:call, parser) do

              @service = tested_service_class.call(tested_service_args)

            end
          end
        end
        assert_mock builder
        assert_mock api_caller
        assert_mock parser

        assert service.failure?
        assert_equal response_state_expected_errors, service.errors[:response_state]
        assert_equal parcels_errors, service.errors[:parcels]
        assert_equal expected_parcels_hash_with_errors, service.result.parcels_hash
      end
    end
  end
end
