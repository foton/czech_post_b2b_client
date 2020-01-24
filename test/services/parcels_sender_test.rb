# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class ParcelsSenderTest < Minitest::Test
      attr_reader :fake_request_builder_result,
                  :fake_api_caller_result,
                  :fake_response_parser_result,
                  :service

      def setup
        @transaction_id = 'transaction1'
        @processing_end_expected_at = Time.parse('2016-02-25T09:30:03.678Z')

        @fake_request_builder_result = '<?xml version="1.0" testing="true" encoding="UTF-8"?>'
        @fake_api_caller_result = OpenStruct.new(code: 200, xml: '<>', error: nil)
        @fake_response_parser_result = {
          async_result: { transaction_id: @transaction_id,
                          processing_end_expected_at: @processing_end_expected_at },
          request: { created_at: Time.parse('2014-03-12T12:33:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-25T08:30:03.678Z') }
        }
        setup_configuration
      end

      def test_it_calls_api_when_data_are_ok
        CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.stub(:call, builder_mock) do
          CzechPostB2bClient::Services::ApiCaller.stub(:call, api_caller_mock) do
            CzechPostB2bClient::ResponseParsers::SendParcelsParser.stub(:call, parser_mock) do
              @service = CzechPostB2bClient::Services::ParcelsSender.call(sending_data: sending_data, parcels: parcels_to_send)
            end
          end
        end

        assert_mock builder_mock # new way of `builder_mock.verify`
        assert_mock api_caller_mock
        assert_mock parser_mock

        assert service.success?
        assert_equal @processing_end_expected_at, service.result.processing_end_expected_at
        assert_equal @transaction_id, service.result.transaction_id
      end

      def test_process_b2b_errors
        skip
      end

      def builder_mock
        @builder_mock ||= begin
          fake = Minitest::Mock.new
          fake.expect(:call, fake_successful_service(fake_request_builder_result)) do |common_data: , parcels:|
            common_data == expected_common_data && parcels == parcels_to_send
          end
          fake
        end
      end

      def api_caller_mock
        @api_caller_mock ||= begin
          fake = Minitest::Mock.new
          fake.expect(:call, fake_successful_service(fake_api_caller_result),[send_parcels_endpoint_url, fake_request_builder_result])
          fake
        end
      end

      def parser_mock
        @parser_mock ||= begin
          fake = Minitest::Mock.new
          fake.expect(:call, fake_successful_service(fake_response_parser_result),[fake_api_caller_result.xml])
          fake
        end
      end

      def fake_successful_service(result)
        OpenStruct.new('success?': true, result: result)
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

      def parcels_to_send
        [1, 2] # ne need for real parcels here
      end

      def send_parcels_endpoint_url
        'https://b2b.postaonline.cz/services/POLService/v1/sendParcels'
      end
    end
  end
end
