# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class ParcelsSenderTest < Minitest::Test
      attr_reader :fake_request_xml, :fake_response_xml, :fake_parser_result, :service

      def setup
        @transaction_id = 'transaction1'
        @processing_end_expected_at = Time.parse('2016-02-25T09:30:03.678Z')

        @fake_request_xml = '<?xml version="1.0" testing="true" encoding="UTF-8"?>'
        @fake_response_xml = '<?xml version="1.0" testing="true" encoding="UTF-8"?>'
        @fake_parser_result = {
          async_result: { transaction_id: @transaction_id,
                          processing_end_expected_at: @processing_end_time },
          request: { created_at: Time.parse('2014-03-12T12:33:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-25T08:30:03.678Z') }
        }
      end

      def test_it_calls_api_when_data_are_ok
        CzechPostB2bClient::RequestBuilders::SendParcelsBuilder.stub(:call, builder_mock) do
          # api call stub
          CzechPostB2bClient::ResponseParsers::SendParcelsParser.stub(:call, parser_mock) do
            @service = CzechPostB2bClient::Services::ParcelsSender.call(sending_data: sending_data, parcels: parcels)
          end
        end

        builder_mock.verify
        parser_mock.verify

        assert service.success?
        assert_kind_of?(@processing_end_expected_at, service.result.processing_end_time)
        assert_kind_of?(@transaction_id, service.result.transaction_id)

      end

      def test_process_b2b_errors
        skip
      end

      def builder_mock
        @builder_mock ||= begin
          fake = Minitest::Mock.new
          fake.expect(:call, fake_request_xml) do |common_data: , parcels:|
            true # verify arguments
          end
          fake
        end
      end

      def parser_mock
        @parser_mock ||= begin
          fake = Minitest::Mock.new
          fake.expect(:call, fake_parser_result, [fake_response_xml])
          fake
        end
      end

      def sending_data
        {}
      end

      def parcels
        []
      end
    end
  end
end
