# frozen_string_literal: true

require 'test_helper'
require 'date'
require 'time'

module CzechPostB2bClient
  module Test
    class GetParcelsPrintingBuilderTest < Minitest::Test
      attr_reader :parcel_codes, :options

      def setup
        @expected_build_time_str = '2019-12-12T12:34:56.789+01:00'
        @contract_id = '123456I'
        @request_id = 42
        @build_time = Time.parse(@expected_build_time_str)

        @options = {
          customer_id: 'EE89',
          contract_number: '2511327004',
          template_id: 7, # 7 => adresní štítek (alonž) - samostatný
          margin_in_mm: { top: 5, left: 3},
          position_order: 1
        }
        @parcel_codes=%w[RR123456789E RR123456789F RR123456789G]

        CzechPostB2bClient.configure do |config|
          config.contract_id = @contract_id
        end
      end

      def expected_xml
        <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <b2bRequest xmlns="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:ns2="https://b2b.postaonline.cz/schema/POLServices-v1">
          <header>
            <idExtTransaction>#{@request_id}</idExtTransaction>
            <timeStamp>#{@expected_build_time_str}</timeStamp>
            <idContract>#{@contract_id}</idContract>
          </header>
          <serviceData>
            <ns2:getParcelsPrinting>
              <ns2:doPrintingHeader>
                <ns2:customerID>#{options[:customer_id]}</ns2:customerID>
                <ns2:contractNumber>#{options[:contract_number]}</ns2:contractNumber>
                <ns2:idForm>#{options[:template_id]}</ns2:idForm>
                <ns2:shiftHorizontal>#{options[:margin_in_mm][:left]}</ns2:shiftHorizontal>
                <ns2:shiftVertical>#{options[:margin_in_mm][:top]}</ns2:shiftVertical>
                <ns2:position>#{options[:position_order]}</ns2:position>
              </ns2:doPrintingHeader>
              <ns2:doPrintingData>
                <ns2:parcelCode>#{parcel_codes[0]}</ns2:parcelCode>
                <ns2:parcelCode>#{parcel_codes[1]}</ns2:parcelCode>
                <ns2:parcelCode>#{parcel_codes[2]}</ns2:parcelCode>
              </ns2:doPrintingData>
            </ns2:getParcelsPrinting>
          </serviceData>
        </b2bRequest>
        XML
      end

      def test_it_build_correct_xml
        Time.stub(:now, @build_time) do
          builder = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder.call(parcel_codes: parcel_codes,
                                                                                        options: options,
                                                                                        request_id: @request_id)
          assert builder.success?
          assert_equal expected_xml, builder.result
        end
      end

      def test_it_assings_request_id_if_it_is_not_present
        Time.stub(:now, @build_time) do
          builder = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder.call(parcel_codes: parcel_codes,
                                                                                        options: options)
          assert builder.success?
          assert_equal expected_xml.gsub(">#{@request_id}</", '>1</'), builder.result
        end
      end

      def test_allows_max_500_parcel_codes
        skip
      end

      def test_allows_max_20_template_ids
        skip
      end

      def test_validate_id_form
        skip
        # 7 - adresní štítek (alonž) - samostatný
        # 8 - adresní štítek (alonž) + dobírková poukázka A
        # 10 - poštovní dobírková poukázka A - samostatná
        # 11 - poštovní dobírková poukázka A - 3x (A4)
        # 12 - Poštovní dobírková poukázka C
        # 13 - Dobírková složenka ČSOB
        # 20 - adresní štítek bianco - 4x (A4)
        # 21 - adresní štítek bianco - samostatný
        # 22 - obálka 1 - C6
        # 23 - obálka 2 - C5
        # 24 - obálka 3 - B4
        # 25 - obálka 4 - DL bez okénka
        # 26 - štítky pro RR - 3x8 (A4)
        # 38 - Integrovaný doklad
        # 39 - adresní štítek bianco - samostatný (na šířku)
        # 40 - Adresní údaje 3x8 (A4)
        # 41 - Dodejka
        # 56 - CN22
        # 57 - CN23
        # 58 - AŠ - samostatný Standardní balík do zahraničí
        # 59 - AŠ - 4xA4 Standardní balík do zahraničí
        # 60 - AŠ - samostatný Cenný balík do zahraničí
        # 61 - 4xA4 Cenný balík do zahraničí
        # 62 - AŠ - samostatný EMS zahraničí
        # 63 - AŠ - 2xA4 EMS do zahraničí
        # 72 - Harmonizovaný štítek pro MZ produkty – samostatný
        # 73 - Harmonizovaný štítek pro MZ produkty –  4x (A4)

        # Formuláře ID 72 a 73 je možno použít pouze pro zásilky s prefixem CE do zemí AT, DE, FR, GR, HR, CH, IS, LU, LV, NO, PL, SK
      end
    end
  end
end
