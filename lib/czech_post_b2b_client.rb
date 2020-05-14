# frozen_string_literal: true

require 'ostruct'
require 'stepped_service'

require 'czech_post_b2b_client/version'
require 'czech_post_b2b_client/configuration'

require 'czech_post_b2b_client/b2b_errors'
require 'czech_post_b2b_client/response_codes'
require 'czech_post_b2b_client/printing_templates'
require 'czech_post_b2b_client/post_services'

require 'czech_post_b2b_client/request_builders'
require 'czech_post_b2b_client/response_parsers'
require 'czech_post_b2b_client/services'

module CzechPostB2bClient
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

  def self.root
    File.dirname __dir__
  end

  def self.certs_path
    File.join(CzechPostB2bClient.root, 'certs')
  end
end
