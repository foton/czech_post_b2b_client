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
          template_id: 7, # 7 => adresni stitek (alonz) - samostatny
          margin_in_mm: { top: 5, left: 3 },
          position_order: 1
        }
        @parcel_codes = %w[RR123456789E RR123456789F RR123456789G]

        setup_configuration(contract_id: @contract_id)
      end

      def expected_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <b2bRequest xmlns=\"https://b2b.postaonline.cz/schema/B2BCommon-v1\" xmlns:ns2=\"https://b2b.postaonline.cz/schema/POLServices-v1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/documents/latest_xsds/B2BCommon.xsd\" xsi:schemaLocation=\"https://b2b.postaonline.cz/schema/POLServices-v1 https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/documents/latest_xsds/B2BPOLServices.xsd\">
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
        parcel_codes_500 = 500.times.collect { |i| "RR123#{i + 100}T" }

        builder = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder.call(parcel_codes: parcel_codes_500,
                                                                                      options: options)

        assert builder.success?

        parcel_codes_501 = parcel_codes_500 + ['RR666111E']
        builder = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder.call(parcel_codes: parcel_codes_501,
                                                                                      options: options)

        assert builder.failed?
        assert_includes builder.errors[:parcel_codes], 'Maximum of 500 parcel codes are allowed!'
      end

      def test_requires_at_least_1_parcel_code
        builder = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder.call(parcel_codes: [],
                                                                                      options: options)

        assert builder.failed?
        assert_includes builder.errors[:parcel_codes], 'Minimum of 1 parcel code is required!'

        builder = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder.call(parcel_codes: ['RR666111E'],
                                                                                      options: options)

        assert builder.success?
      end

      def test_allows_max_20_template_ids
        skip 'There can be up to 20 `idForm` nodes, but I do not know how it works yet'
      end

      def test_validate_id_form # rubocop:disable Metrics/AbcSize
        allowed_template_ids.each do |template_id|
          options.merge!(template_id: template_id)
          builder = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder.call(parcel_codes: parcel_codes,
                                                                                        options: options)

          assert builder.success?, "Build should be succesfull for template_id: '#{template_id}'"
        end

        [1, 2, 99].each do |template_id|
          options.merge!(template_id: template_id)
          builder = CzechPostB2bClient::RequestBuilders::GetParcelsPrintingBuilder.call(parcel_codes: parcel_codes,
                                                                                        options: options)

          assert builder.failed?, "Build should NOT be succesfull for template_id: '#{template_id}'"
          assert_includes builder.errors[:template_id], "Value '#{template_id}' is not allowed!"
        end
      end

      def allowed_template_ids
        # see CzechPostB2bClient::PrintingTemplates
        [7, 8, 10, 11, 12, 13, 20, 21, 22, 23, 24, 25, 26, 38, 39, 40, 41, 56, 57, 58, 59, 60, 61, 62, 63, 72, 73]
      end
    end
  end
end
