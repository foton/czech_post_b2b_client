# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    module CommunicatorServiceTestingBase
      # these have to be set in `setup`
      attr_reader :endpoint_path, :builder_service_class, :parser_service_class,
                  :tested_service_class, :tested_service_args,
                  :builder_expected_args, :builder_expected_errors,
                  :fake_response_parser_result

      # we manage these here
      attr_reader :service

      def api_caller_service_class
        CzechPostB2bClient::Services::ApiCaller
      end

      def fake_request_builder_result
        '<?xml version="1.0" testing="true" encoding="UTF-8"?>'
      end

      def fake_api_caller_result
        OpenStruct.new(code: 200, xml: '<>', error: nil)
      end

      def fake_response_parser_result_shared_part
        {
          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '64' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z') }
        }
      end

      def test_it_calls_api_when_data_are_ok
        builder = builder_mock(expected_args: builder_expected_args,
                               returns: fake_successful_service(fake_request_builder_result))
        api_caller = api_caller_mock(expected_args: { endpoint_path: endpoint_path, xml: fake_request_builder_result },
                                     returns: fake_successful_service(fake_api_caller_result))
        parser = parser_mock(expected_args: { xml: fake_api_caller_result.xml },
                             returns: fake_successful_service(fake_response_parser_result))

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

        assert service.success?
        succesful_call_asserts(service)
      end


      def test_it_handle_builder_errors
        expected_errors = builder_expected_errors
        builder = builder_mock(expected_args: builder_expected_args,
                               returns: fake_failing_service(expected_errors))

        builder_service_class.stub(:call, builder) do
          api_caller_service_class.stub(:call, not_to_be_called_mock('ApiCaller')) do

            @service = tested_service_class.call(tested_service_args)

          end
        end

        assert_mock builder

        assert service.failure?
        assert_equal full_messages_from(expected_errors), service.errors[:request_builder]
      end

      def test_it_handle_api_caller_errors
        expected_errors = { network: ['Down'], b2b: ['unreachable'] }
        builder = builder_mock(expected_args: builder_expected_args,
                               returns: fake_successful_service(fake_request_builder_result))
        api_caller = api_caller_mock(expected_args: { endpoint_path: endpoint_path, xml: fake_request_builder_result },
                                     returns: fake_failing_service(expected_errors, fake_api_caller_result))

        builder_service_class.stub(:call, builder) do
          api_caller_service_class.stub(:call, api_caller) do
            parser_service_class.stub(:call, not_to_be_called_mock('ResponseParser')) do

              @service = tested_service_class.call(tested_service_args)

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
        builder = builder_mock(expected_args: builder_expected_args,
                               returns: fake_successful_service(fake_request_builder_result))
        api_caller = api_caller_mock(expected_args: { endpoint_path: endpoint_path, xml: fake_request_builder_result },
                                     returns: fake_successful_service(fake_api_caller_result))
        parser = parser_mock(expected_args: { xml: fake_api_caller_result.xml },
                             returns: fake_failing_service(expected_errors))

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
        assert_equal full_messages_from(expected_errors), service.errors[:response_parser]
      end

      def builder_mock(expected_args:, returns:)
        raise "implement me(#{expected_args}, #{returns})"
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

      def full_messages_from(err_hash)
        err_hash.each_with_object([]) do |(field, messages), f_messages|
          messages.each { |message| f_messages << "#{field}: #{message}" }
        end
      end

      def succesful_call_asserts(_orchestrator_service)
        raise 'implement me'
      end

      def configuration
        CzechPostB2bClient.configuration
      end
    end
  end
end
