# frozen_string_literal: true

require 'stepped_service'

require 'czech_post_b2b_client/version'
require 'czech_post_b2b_client/configuration'
require 'czech_post_b2b_client/printing_templates'
require 'czech_post_b2b_client/request_builders'
require 'czech_post_b2b_client/response_parsers'

module CzechPostB2bClient
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.logger
    self.configuration.logger
  end
end
