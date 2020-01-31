# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class ParcelsSendProcessUpdaterTest < Minitest::Test
      attr_reader :fake_request_builder_result,
                  :fake_api_caller_result,
                  :fake_response_parser_result,
                  :transaction_id,
                  :service,
                  :endpoint_path

      def setup
        @transaction_id = 'transaction1'
        @expected_parcels_hash = {
          '1' => { parcel_code: 'RA12354678', state_code: 1, state_text: 'OK' },
          'second' => { parcel_code: 'RA12354679', state_code: 1, state_text: 'OK' }
        }
        @endpoint_path = '/getResultParcels' # 'https://b2b.postaonline.cz/services/POLService/v1/getResultParcels'

        @fake_request_builder_result = '<?xml version="1.0" testing="true" encoding="UTF-8"?>'
        @fake_api_caller_result = OpenStruct.new(code: 200, xml: '<>', error: nil)
        @fake_response_parser_result = {
          parcels: @expected_parcels_hash,
          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '64' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z') }
        }

        setup_configuration
      end

      def test_it_calls_api_when_data_are_ok
        builder = builder_mock(expected_args: { transaction_id: transaction_id },
                               returns: fake_successful_service(fake_request_builder_result))
        api_caller = api_caller_mock(expected_args: { endpoint_path: endpoint_path, xml: fake_request_builder_result },
                                     returns: fake_successful_service(fake_api_caller_result))
        parser = parser_mock(expected_args: { xml: fake_api_caller_result.xml },
                             returns: fake_successful_service(fake_response_parser_result))

        CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder.stub(:call, builder) do
          CzechPostB2bClient::Services::ApiCaller.stub(:call, api_caller) do
            CzechPostB2bClient::ResponseParsers::GetResultParcelsParser.stub(:call, parser) do

              @service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id: transaction_id)

            end
          end
        end

        assert_mock builder
        assert_mock api_caller
        assert_mock parser

        assert service.success?
        assert_equal @expected_parcels_hash, service.result.parcels_hash
      end


      def test_it_handle_builder_errors
        expected_errors = { parcels: ['Too many'], common_data: ['Missing :parcels_sending_date value', 'xxx'] }
        builder = builder_mock(expected_args: { transaction_id: transaction_id },
                               returns: fake_failing_service(expected_errors))

        CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder.stub(:call, builder) do
          CzechPostB2bClient::Services::ApiCaller.stub(:call, not_to_be_called_mock('ApiCaller')) do

            @service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id: transaction_id)

          end
        end

        assert_mock builder

        assert service.failure?
        assert_equal full_messages_from(expected_errors), service.errors[:request_builder]
      end

      def test_it_handle_api_caller_errors
        expected_errors = { network: ['Down'], b2b: ['unreachable'] }
        builder = builder_mock(expected_args: { transaction_id: transaction_id },
                               returns: fake_successful_service(fake_request_builder_result))
        api_caller = api_caller_mock(expected_args: { endpoint_path: endpoint_path, xml: fake_request_builder_result },
                                     returns: fake_failing_service(expected_errors, fake_api_caller_result))

        CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder.stub(:call, builder) do
          CzechPostB2bClient::Services::ApiCaller.stub(:call, api_caller) do
            CzechPostB2bClient::ResponseParsers::GetResultParcelsParser.stub(:call, not_to_be_called_mock('ResponseParser')) do

              @service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id: transaction_id)

            end
          end
        end

        assert_mock builder
        assert_mock api_caller

        assert service.failure?
        assert_equal full_messages_from(expected_errors), service.errors[:api_caller]
      end

      def test_it_handle_parser_errors
        expected_errors = { xml: ['Response XML can not be parsed'] }
        builder = builder_mock(expected_args: { transaction_id: transaction_id },
                               returns: fake_successful_service(fake_request_builder_result))
        api_caller = api_caller_mock(expected_args: { endpoint_path: endpoint_path, xml: fake_request_builder_result },
                                     returns: fake_successful_service(fake_api_caller_result))
        parser = parser_mock(expected_args: { xml: fake_api_caller_result.xml },
                             returns: fake_failing_service(expected_errors))

        CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder.stub(:call, builder) do
          CzechPostB2bClient::Services::ApiCaller.stub(:call, api_caller) do
            CzechPostB2bClient::ResponseParsers::GetResultParcelsParser.stub(:call, parser) do

              @service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id: transaction_id)

            end
          end
        end

        assert_mock builder
        assert_mock api_caller
        assert_mock parser

        assert service.failure?
        assert_equal full_messages_from(expected_errors), service.errors[:response_parser]
      end


      def builder_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |transaction_id:|
          transaction_id == expected_args[:transaction_id]
        end
        fake
      end

      def api_caller_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |endpoint_path:, xml:|
          endpoint_path == expected_args[:endpoint_path] && xml == expected_args[:xml]
        end

        fake
      end

      def parser_mock(expected_args:, returns:)
        fake = Minitest::Mock.new
        fake.expect(:call, returns) do |xml:|
          xml == expected_args[:xml]
        end
        fake
      end

      def not_to_be_called_mock(not_allowed_service)
        ->(*_args) { raise "#{not_allowed_service} should not receive .call!" }
      end

      def fake_successful_service(result)
        OpenStruct.new('success?': true, 'failed?': false, result: result)
      end

      def fake_failing_service(errors, result = nil)
        err = SteppedService::Errors[errors]
        OpenStruct.new('success?': false, 'failed?': true, errors: err, result: result)
      end

      def sending_data
        sd = full_common_data.dup
        sd.delete(:contract_id) # taken from config
        sd.delete(:customer_id) # taken from config
        sd.delete(:sending_post_office_code) # taken from config
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

      def full_messages_from(err_hash)
        err_hash.each_with_object([]) do |(field, messages), f_messages|
          messages.each { |message| f_messages << "#{field}: #{message}" }
        end
      end


    end
  end
end
