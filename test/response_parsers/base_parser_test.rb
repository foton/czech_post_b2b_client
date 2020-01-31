# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class BaseParserTest < Minitest::Test
      def test_recovers_from_unexpected_valid_xml
        parser = CzechPostB2bClient::ResponseParsers::GetResultParcelsParser.call(xml: valid_get_stats_response_xml)

        assert parser.failed?
        assert_equal ['Parsed XML can not be converted to result hash. Is it correct response for this parser?'],
                     parser.errors[:xml]

        assert_equal '16', parser.result[:response_hash].dig('b2bSyncResponse', 'serviceData', 'getStatsResponse', 'importAll')
        assert parser.result[:result_builder_error].include?("undefined method `dig' for nil:NilClass")
        assert parser.result[:result_builder_error].include?(" at line: #{CzechPostB2bClient.root}") # full path to failing line
      end

      def test_recovers_from_bad_response_xml
        parser = CzechPostB2bClient::ResponseParsers::BaseParser.call(xml: bad_response_xml)

        assert parser.failed?
        assert parser.errors[:xml].first.include?('XML can not be parsed! Is it valid XML?') # parser error is appended to this message

        assert_equal bad_response_xml, parser.result[:xml]
        assert parser.result[:parser_error].include?('invalid format, expected < at line 1, column 1')
      end

      def bad_response_xml
        'NO XML AT ALL'
      end

      def valid_get_stats_response_xml
        # response for GetStatsParser
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <v1:b2bSyncResponse xmlns:v1="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:v1_1="https://b2b.postaonline.cz/schema/POLServices-v1">
            <v1:header>
              <v1:timeStamp>2016-02-25T08:30:03.678Z</v1:timeStamp>
              <v1:b2bRequestHeader>
                <v1:idExtTransaction>42</v1:idExtTransaction>
                <v1:timeStamp>2014-03-12T12:33:34.573Z</v1:timeStamp>
                <v1:idContract>25195667001</v1:idContract>
              </v1:b2bRequestHeader>
            </v1:header>
            <v1:serviceData>
              <v1_1:getStatsResponse>
                <v1_1:importAll>16</v1_1:importAll>
                <v1_1:importErr>13</v1_1:importErr>
                <v1_1:importOk>3</v1_1:importOk>
                <v1_1:parcels>43</v1_1:parcels>
              </v1_1:getStatsResponse>
            </v1:serviceData>
          </v1:b2bSyncResponse>
        XML
      end
    end
  end
end
