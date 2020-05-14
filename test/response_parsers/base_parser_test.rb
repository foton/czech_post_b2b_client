# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class BaseParserTest < Minitest::Test
      def test_recovers_from_unexpected_valid_xml
        parser = CzechPostB2bClient::ResponseParsers::GetResultParcelsParser.call(xml: valid_get_stats_response_xml)

        assert parser.failed?
        assert_equal ['Cannot find `getResultParcelsResponse` in `serviceData` node.',
                      'Parsed XML can not be converted to result hash. Is it correct response for this parser?'],
                     parser.errors[:xml]

        assert_equal '16', parser.result[:response_hash].dig('b2bSyncResponse',
                                                             'serviceData',
                                                             'getStatsResponse',
                                                             'importAll')
      end

      def test_recovers_from_bad_response_xml
        parser = CzechPostB2bClient::ResponseParsers::BaseParser.call(xml: bad_response_xml)

        assert parser.failed?
        # parser error is appended to this message
        assert parser.errors[:xml].first.include?('XML can not be parsed! Is it valid XML?')

        assert_equal bad_response_xml, parser.result[:xml]
        assert parser.result[:parser_error].include?('invalid format, expected < at line 1, column 1')
      end

      def bad_response_xml
        'NO XML AT ALL'
      end

      def valid_get_stats_response_xml
        fixture_response_xml('getStats_ok.xml')
      end
    end
  end
end
