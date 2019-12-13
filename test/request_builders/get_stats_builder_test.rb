# frozen_string_literal: true

require 'test_helper'
require 'date'
require 'time'

module CzechPostB2bClient
  module Test
    class GetStatsBuilderTest < Minitest::Test
      def setup
        @expected_from_date_str = '2019-06-18T00:00:00.000+02:00'
        @expected_to_date_str = '2019-12-12T00:00:00.000+01:00'
        @expected_build_time_str = '2019-12-12T12:34:56.789+01:00'
        @contract_id = '123456I'

        @from_date = Date.parse(@expected_from_date_str)
        @to_date = Date.parse(@expected_to_date_str)
        @build_time = Time.parse(@expected_build_time_str)

        CzechPostB2bClient.configure do |config|
          config.contract_id = @contract_id
        end
      end

      def expected_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <b2bRequest xmlns="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:ns2="https://b2b.postaonline.cz/schema/POLServices-v1">
            <header>
              <idExtTransaction>1</idExtTransaction>
              <timeStamp>#{@expected_build_time_str}</timeStamp>
              <idContract>#{@contract_id}</idContract>
            </header>
            <serviceData>
              <ns2:getStats>
                <ns2:dateBegin>#{@expected_from_date_str}</ns2:dateBegin>
                <ns2:dateEnd>#{@expected_to_date_str}</ns2:dateEnd>
              </ns2:getStats>
            </serviceData>
          </b2bRequest>
        XML
      end

      def test_it_build_correct_xml
        Time.stub(:now, @build_time) do
          builder = CzechPostB2bClient::RequestBuilders::GetStatsBuilder.call(from_date: @from_date,
                                                                         to_date: @to_date)
          assert builder.success?
          assert_equal expected_xml, builder.result
        end
      end
    end
  end
end
