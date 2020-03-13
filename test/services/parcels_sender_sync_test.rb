# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class ParcelsSenderTest < Minitest::Test
#      include CzechPostB2bClient::Test::CommunicatorServiceTestingBase

      attr_reader :transaction_id, :processing_end_expected_at

      def setup
        setup_configuration
      end

      def test_no_need_to_wait
        skip " not yet implemented"
        # /sendParcelsSync
      end
    end
  end
end
