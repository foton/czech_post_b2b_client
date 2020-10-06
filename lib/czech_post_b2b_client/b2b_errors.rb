# frozen_string_literal: true

# rubocop:disable Style/AsciiComments, Layout/LineLength

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

# B2B errors, which can be returned in response `B2BFaultMessage`
#
# Do not miss `CzechPostB2bClient::B2BErrors.all_error_classes` and `CzechPostB2bClient::B2BErrors.new_by_code`,
# they have to be at end of module to work properly
module CzechPostB2bClient
  class Error < StandardError; end

  module B2BErrors
    class BaseError < CzechPostB2bClient::Error
      @code = 'undefined'
      @message = 'Unspecified B2B error'


      class << self
        attr_reader :code
      end

      class << self
        attr_reader :message
      end

      def initialize(details = '')
        self.details = details
      end

      attr_accessor :details
      def code
        self.class.code
      end

      def message
        "#{self.class.message} -- #{details}"
      end
    end

    class UnauthorizedRoleAccessError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 1
      @message = 'Klient nemá definovanou požadovanou roli na službu (neexistuje žádný záznam pro požadovanou službu)'
    end

    class UnauthorizedContractAccessError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 2
      @message = 'Klient nemá definován ke službě uvedený identifikátor smlouvy'
    end

    class InternalB2BServerError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 3
      @message = 'Interní chyba systému B2B'
    end

    class InternalDataPersistenceServerError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 4
      @message = 'Interní chyba aplikace (perzistence)'
    end

    class InternalBackendServerError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 5
      @message = 'Interní chyba ISČP'
    end

    class BadRequestError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 7
      @message = 'Request nemá očekávaný formát (obvykle text/xml)'
    end

    class CustomerRequestsCountOverflowError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 8
      @message = 'Překročen parametr maximálního počtu volání za jeden den pro klienta'
    end

    class ServiceBusyError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 9
      @message = 'Překročen parametr maximálního počtu volání služby v daný okamžik, zkuste to později'
    end

    class ProcessingUnfinishedYetError < CzechPostB2bClient::B2BErrors::BaseError
      @code = 10
      @message = 'Zpracování není ještě ukončeno (u async operací)'
    end

    # have t be at end of file, to collect all classes defined before
    def self.all_error_classes
      ObjectSpace.each_object(CzechPostB2bClient::B2BErrors::BaseError.singleton_class)
    end

    def self.new_by_code(code, details = '')
      klass = all_error_classes.detect { |k| k.code == code }
      raise "B2BError with code: #{code} is unknown!" unless klass

      klass.new(details)
    end
  end
end

# rubocop:enable Style/AsciiComments, Layout/LineLength
