# frozen_string_literal: true

require 'test_helper'
# rubocop:disable Style/AsciiComments

# response <B2BFaultMessage>
# Chybový kód | Detail chyby            | Popis
# -----------------------------------------------
#   1  |  UNAUTHORIZED_ROLE_ACCESS      |  Klient nemá definovanou požadovanou roli na službu
#                                       |  (neexistuje žádný záznam pro požadovanou službu)
#   2  |  UNAUTHORIZED_CONTRACT_ACCES   |  Klient nemá definován ke službě uvedený identifikátor smlouvy
#   3  |  INTERNAL_ERROR_B2B            |  Interní chyba systému B2B
#   4  |  INTERNAL_ERROR_DATA           |  Interní chyba aplikace (perzistence)
#   5  |  INTERNAL_ERROR_BACKEND        |  Interní chyba ISČP
#   7  |  BAD_REQUEST                   |  Request nemá očekávaný formát (obvykle text/xml)
#   8  |  OVERFLOW_MAX_CALL_COUNT       |  Překročen parametr maximálního počtu volání za jeden den pro klienta
#   9  |  TRY_AGAIN_LATER               |  Překročen parametr maximálního počtu volání služby v daný okamžik
#   10 |  UNFINISHED_PROCESS            |  Zpracování není ještě ukončeno  (u async operací)

# ENDPOINT https://b2b.postaonline.cz/services/POLService/v1/:service

## https://b2b.postaonline.cz/services/POLService/v1/sendParcels
#  odeslání dat o zásilkách k předzpracování poštou
#  - V případě, že je podací místo identifikováno prostřednictvím locationNumber,
#     není nutná identifikace odesílatele prostřednictvím doParcelHeader.senderAddress
#  - Velikost odesílaných dat maximálně 3MB, max. 15_000 volání denně

## https://b2b.postaonline.cz/services/POLService/v1/getResultParcels
#  zjištění výsledku zpracování sendParcels
#  - Do ukončení zpracování předaných dat (ze SendParcels) vrací chybový kód 10 UNFINISHED_PROCESS
#  - max. 1_000_000 volání denně

## https://b2b.postaonline.cz/services/POLService/v1/getStats
#  zjištění statistických informací o datech předaných prostřednictvím operace sendParcels.
#  - max. 1_000 volání denně

## https://b2b.postaonline.cz/services/POLService/v1/getParcelState
#  získání seznamu stavů zásilek.
#  - max. 1_000 volání denně

## https://b2b.postaonline.cz/services/POLService/v1/getParcelsPrinting
#  získání adresních štítků
#  - max. 1000000 volání denně

# rubocop:enable Style/AsciiComments

module CzechPostB2bClient
  module Test
    class ApiCallerTest < Minitest::Test
      attr_reader :send_parcels_endpoint_url, :fake_request_builder_result

      def setup
        setup_configuration
        @send_parcels_endpoint_url = 'https://b2b.postaonline.cz/services/POLService/v1/sendParcels'
        @fake_request_builder_result = '<?xml version="1.0" testing="true" encoding="UTF-8"?>'
      end

      def test_it_do_the_call
        fake_response_body = '<?xml version="1.0" testing="true" encoding="UTF-8"?><body></body>'

        stub_request(:post, send_parcels_endpoint_url)
          .with(headers: expected_request_headers)
          .to_return(status: 200, body: fake_response_body, headers: {})

        service = CzechPostB2bClient::Services::ApiCaller.call(endpoint_path: '/sendParcels',
                                                               xml: fake_request_builder_result)

        assert service.success?
        assert_equal 200, service.result.code
        assert_equal fake_response_body, service.result.xml
      end

      def test_it_can_handle_b2b_errors # rubocop:disable  Metrics/AbcSize
        error = CzechPostB2bClient::B2BErrors::CustomerRequestsCountOverflowError.new
        fake_response_body = b2b_fault_response_with_error_code(error.code)

        stub_request(:post, send_parcels_endpoint_url)
          .with(headers: expected_request_headers)
          .to_return(status: 200, body: fake_response_body, headers: {})
        # 200 is my guess for what code is actually returned on errors

        service = CzechPostB2bClient::Services::ApiCaller.call(endpoint_path: '/sendParcels',
                                                               xml: fake_request_builder_result)

        assert service.failure?
        assert_equal 200, service.result.code
        assert_equal fake_response_body, service.result.xml
        assert_includes service.errors[:b2b], error.message
      end

      def test_it_can_handle_connection_errors
        CzechPostB2bClient::Services::ApiCaller::KNOWN_CONNECTION_ERRORS.each do |error_class|
          error_raiser = connection_mock_raising(error_class)
          expected_err_message = "#{error_class} > #{send_parcels_endpoint_url}"

          service = nil
          Net::HTTP.stub(:start, error_raiser) do
            service = CzechPostB2bClient::Services::ApiCaller.call(endpoint_path: '/sendParcels',
                                                                   xml: fake_request_builder_result)
          end

          assert service.failure?, "Service should fail for #{error_class}"
          assert_equal 500, service.result.code, "result.code shloud be 500 for #{error_class}"
          assert_equal '', service.result.xml, "result.xml shloud be '' for #{error_class}"
          assert service.errors[:connection].first.include?(expected_err_message)
        end
      end

      def b2b_fault_response_with_error_code(error_code)
        # <v1:B2BFaultMessage xmlns:v1="https://b2b.postaonline.cz/schema/B2BCommon-v1">

        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <v1:B2BFaultMessage xmlns:v1="https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/doc/20181023/B2BCommon-v1.1.xsd">
            <v1:errorDetail>  Error text </v1:errorDetail>
            <v1:errorCode>#{error_code}</v1:errorCode>
          </v1:B2BFaultMessage>
        XML
      end

      def expected_request_headers
        { 'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby' }
      end

      def connection_mock_raising(error_class)
        fake = Minitest::Mock.new
        fake.expect(:request, nil) do |_args|
          raise error_class
        end
        fake
      end
    end
  end
end
