# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetStatsParserTest < Minitest::Test
      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetStatsParser.call(xml: fixture_response_xml('getStats_ok.xml'))
        assert parser.success?
        assert_equal expected_struct, parser.result
      end

      def expected_struct
        {
          imports: { requested: 16, with_errors: 13, successful: 3, imported_parcels: 43 },
          request: { created_at: Time.parse('2014-03-12T12:33:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-25T08:30:03.678Z') }
        }
      end
    end
  end
end
