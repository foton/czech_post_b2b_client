# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class B2BErrorsTest < Minitest::Test
      def test_it_can_create_new_from_code
        code_to_klass.each_pair do |code, klass|
          instance = CzechPostB2bClient::B2BErrors.new_by_code(code)
          assert_kind_of klass,
                         instance,
                         "For code #{code} expected class is #{klass} but got #{instance.class}"
        end
      end

      def test_raises_error_for_unknown_code
        err = assert_raises(RuntimeError) { CzechPostB2bClient::B2BErrors.new_by_code(6) }
        assert_equal 'B2BError with code: 6 is unknown!', err.message
      end

      def test_it_knows_all_error_classes
        assert code_to_klass.values.compact.size, CzechPostB2bClient::B2BErrors.all_error_classes.size
      end

      def code_to_klass
        {
          1 => CzechPostB2bClient::B2BErrors::UnauthorizedRoleAccessError,
          2 => CzechPostB2bClient::B2BErrors::UnauthorizedContractAccessError,
          3 => CzechPostB2bClient::B2BErrors::InternalB2BServerError,
          4 => CzechPostB2bClient::B2BErrors::InternalDataPersistenceServerError,
          5 => CzechPostB2bClient::B2BErrors::InternalBackendServerError,

          7 => CzechPostB2bClient::B2BErrors::BadRequestError,
          8 => CzechPostB2bClient::B2BErrors::CustomerRequestsCountOverflowError,
          9 => CzechPostB2bClient::B2BErrors::ServiceBusyError,
          10 => CzechPostB2bClient::B2BErrors::ProcessingUnfinishedYetError
        }
      end
    end
  end
end
