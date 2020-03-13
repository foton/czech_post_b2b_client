# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class SendParcelsParserTest < Minitest::Test
      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::SendParcelsParser.call(xml: fixture_response_xml('sendParcels_ok.xml'))
        assert parser.success?
        assert_equal expected_struct, parser.result
      end

      def expected_struct
        {
          async_result: { transaction_id: 'D4647E8A-0170-4000-E000-62A80AA06329',
                          processing_end_expected_at: Time.parse('2016-02-25T09:30:03.678Z') },
          request: { created_at: Time.parse('2014-03-12T12:33:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-25T08:30:03.678Z') }
        }
      end
    end
  end
end
