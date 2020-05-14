# frozen_string_literal: true

require 'minitest/autorun'
require 'pry-byebug'
require 'minitest/reporters'
require_relative './support/rake_rerun_reporter'
require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

reporter_options = { color: true, slow_count: 5, verbose: false, rerun_prefix: 'bundle exec' }
Minitest::Reporters.use! [Minitest::Reporters::RakeRerunReporter.new(reporter_options),
                          Minitest::Reporters::SpecReporter.new]

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'czech_post_b2b_client'
require_relative './support/helpers'
require_relative './support/communicator_service_testing_base'
