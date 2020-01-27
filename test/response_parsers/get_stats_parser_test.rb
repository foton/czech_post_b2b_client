# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetStatsParserTest < Minitest::Test
      def response_xml
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

      def expected_struct
        {
          imports: { requested: 16, with_errors: 13, sucessfull: 3, imported_parcels: 43 },
          request: { created_at: Time.parse('2014-03-12T12:33:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-25T08:30:03.678Z') }
        }
      end

      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetStatsParser.call(xml: response_xml)
        assert parser.success?
        assert_equal expected_struct, parser.result
      end
    end
  end
end
