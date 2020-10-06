# frozen_string_literal: true

require 'logger'

module CzechPostB2bClient
  class Logger
    attr_reader :target_logger, :min_log_level

    LEVELS = { debug: 0, info: 1, error: 2 }.freeze

    def initialize(configuration)
      @target_logger = configuration.logger
      @min_log_level = configuration.log_messages_at_least_as
    end

    def log(original_level, message)
      puts("#{message} #{original_level} => #{modified_log_level(original_level)}")
      target_logger.send(modified_log_level(original_level), message)
    end

    LEVELS.each_key do |level|
      define_method(level) { |message| log(level, message) }
    end

    private

    def modified_log_level(original_level)
      LEVELS[original_level] > LEVELS[min_log_level] ? original_level : min_log_level
    end
  end
end
