# frozen_string_literal: true

require 'test_helper'
# rubocop:disable Style/AsciiComments

# response <B2BFaultMessage>
# Chybový kód | Detail chyby            | Popis
# -----------------------------------------------
#   1  |  UNAUTHORIZED_ROLE_ACCESS      |  Klient nemá definovanou požadovanou roli na službu (neexistuje žádný záznam pro požadovanou službu)
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
#  - V případě, že je podací místo identifikováno prostřednictvím locationNumber, není nutná identifikace odesílatele prostřednictvím doParcelHeader.senderAddress
#  - Velikost odesílaných dat maximálně 3MB, max. 15_000 volání denně

## https://b2b.postaonline.cz/services/POLService/v1/getResultParcels
#  zjištění výsledku zpracování sendParcels
#  - Do ukončení zpracování předaných dat (ze SendParcels) vrací chybový kód 10 UNFINISHED_PROCESS  - Zpracování není ještě ukončeno
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
      def setup
        setup_configuration
      end

      def test_it_do_the_call
        send_parcels_endpoint_url = 'https://b2b.postaonline.cz/services/POLService/v1/sendParcels'
        fake_request_builder_result = '<?xml version="1.0" testing="true" encoding="UTF-8"?>'
        fake_response_body = '<?xml version="1.0" testing="true" encoding="UTF-8"?><body></body>'

        stub_request(:post, send_parcels_endpoint_url)
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'User-Agent' => 'Ruby' })
          .to_return(status: 200, body: fake_response_body, headers: {})

        service = CzechPostB2bClient::Services::ApiCaller.call(endpoint_path: '/sendParcels',
                                                               xml: fake_request_builder_result)

        assert service.success?
        assert_equal 200, service.result.code
        assert_equal fake_response_body, service.result.xml
      end

      def test_it_can_handle_b2b_errors
        skip
      end

      def test_it_can_handle_connection_errors
        skip
      end
    end
  end
end
