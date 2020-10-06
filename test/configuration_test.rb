# frozen_string_literal: true

require 'test_helper'

class CzechPostB2bClientTest < Minitest::Test
  def setup
    setup_configuration
  end

  def test_it_respects_minimum_log_level
    CzechPostB2bClient.configuration.stub(:logger, fake_logger) do
      CzechPostB2bClient.configuration.stub(:log_messages_at_least_as, :info) do
        log_messages.each_pair { |level, msg| CzechPostB2bClient.logger.send(level, msg) }
      end
    end

    assert_mock fake_logger
  end

  def fake_logger
    @fake_logger ||= begin
      fake_logger = Minitest::Mock.new
      fake_logger.expect(:info, true, [log_messages[:debug]])
      fake_logger.expect(:info, true, [log_messages[:info]])
      fake_logger.expect(:error, true, [log_messages[:error]])
    end
  end

  def log_messages
    @log_messages ||= { debug: 'Debug information',
                        info: 'Info information',
                        error: 'Error information' }
  end
end
