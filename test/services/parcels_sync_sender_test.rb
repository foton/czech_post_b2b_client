# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class ParcelsSyncSenderTest < Minitest::Test
      include CzechPostB2bClient::Test::CommunicatorServiceTestingBase

      def setup # rubocop:disable Metrics/MethodLength
        setup_configuration

        @endpoint_path = '/parcelServiceSync' # 'https://b2b.postaonline.cz/services/POLService/v1/parcelServiceSync'

        @print_params = { template_id: 21,
                          margin_in_mm: { top: 2, left: 1 },
                          position_order: 3 }
        @expected_parcels_hash = {
          'package_1' => { parcel_code: 'RA12354679',
                           states: [{ code: 1, text: 'OK' }],
                           print: { pdf_content: 'very big pdf extracted from base64 string',
                                    state: { code: 1, text: 'OK' } } }
        }

        parcels_to_send = [parcel_1of2]

        @tested_service_class = CzechPostB2bClient::Services::ParcelsSyncSender
        @tested_service_args = { sending_data: sending_data, parcels: parcels_to_send }

        @builder_service_class = CzechPostB2bClient::RequestBuilders::ParcelServiceSyncBuilder
        @parser_service_class = CzechPostB2bClient::ResponseParsers::ParcelServiceSyncParser

        # builder accepts PARCEL, not PARCELS!
        @builder_expected_args = { common_data: expected_common_data, parcel: parcel_1of2 }
        @builder_expected_errors = { parcels: ['Too many'],
                                     common_data: ['Missing :parcels_sending_date value', 'xxx'] }

        # parser returns accepts PARCEL, not PARCELS!
        @fake_response_parser_result = fake_response_parser_result_shared_part.merge(parcel: @expected_parcels_hash)
        @fake_response_parser_result[:response].merge!(state: { code: 1, text: 'OK' })
      end

      def succesful_call_asserts(tested_service)
        puts(tested_service.result.parcels_hash)
        assert_equal @expected_parcels_hash, tested_service.result.parcels_hash
      end

      def test_it_fails_with_errors_in_response_data # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        expected_parcels_hash_with_errors = {
          'package_1' => { parcel_code: nil, states: [{ code: 104, text: 'INVALID_WEIGHT' },
                                                      { code: 261, text: 'MISSING_SIZE_CATEGORY' }] }
        }
        fake_response_parser_result_with_errors = fake_response_parser_result_shared_part
        fake_response_parser_result_with_errors.merge!(parcel: expected_parcels_hash_with_errors)
        fake_response_parser_result_with_errors[:response].merge!(state: { code: 19, text: 'BATCH_INVALID' })

        response_state_expected_errors = [CzechPostB2bClient::ResponseCodes.new_by_code(19).to_s]
        parcels_errors = ["Parcel[package_1] => #{CzechPostB2bClient::ResponseCodes.new_by_code(104)}",
                          "Parcel[package_1] => #{CzechPostB2bClient::ResponseCodes.new_by_code(261)}"]

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

      def builder_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |common_data:, parcel:|
          common_data == expected_args[:common_data] && parcel == expected_args[:parcel]
        end
        fake
      end

      def parcel_1of2
        @parcel_1of2 ||= {
          addressee: full_addressee_data,
          params: { parcel_id: 'package_1',
                    parcel_code_prefix: 'BA',
                    weight_in_kg: 12_345.678,
                    parcel_order: 1,
                    parcels_count: 2 }
        }
      end

      def sending_data
        sd = full_common_data.dup
        sd.delete(:contract_id) # taken from config
        sd.delete(:customer_id) # taken from config
        sd.delete(:sending_post_office_code) # taken from config
        sd[:print_params] = @print_params
        sd
      end

      def data_from_config
        { contract_id: configuration.contract_id,
          customer_id: configuration.customer_id,
          sending_post_office_code: configuration.sending_post_office_code }
      end

      def expected_common_data
        data_from_config.merge(sending_data)
      end
    end
  end
end
