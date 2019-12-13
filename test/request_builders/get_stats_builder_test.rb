require "test_helper"
require 'date'

module CzechPostB2bClient
  module Test
    class GetStatsBuilderTest < Minitest::Test
      def setup
        @from_date = Date.today - 2
        @to_date = Date.today
      end

      def expected_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <b2bRequest xmlns="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:ns2="https://b2b.postaonline.cz/schema/POLServices-v1">
            <header>
              <idExtTransaction>1</idExtTransaction>
              <timeStamp>2014-03-12T13:33:34.573+01:00</timeStamp>
              <idContract>25195667001</idContract>
            </header>
            <serviceData>
              <ns2:getStats>
                <ns2:dateBegin>2016-02-18T00:00:00.000+02:00</ns2:dateBegin>
                <ns2:dateEnd>2016-02-18T23:59:00.000+02:00</ns2:dateEnd>
              </ns2:getStats>
            </serviceData>
          </b2bRequest>
        XML
      end

      def test_it_build_correct_xml
        xml = CzechPostB2bClient::RequestBuilders::GetStatsBuilder.new(from_date: @from_date , to_date: @to_date).to_xml
        assert_equal expected_xml, xml
      end
    end
  end
end
