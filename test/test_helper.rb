# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'pry-byebug'
require 'minitest/reporters'
require_relative './support/rake_rerun_reporter'
require 'czech_post_b2b_client'

reporter_options = { color: true, slow_count: 5, verbose: false, rerun_prefix: 'bundle exec' }
Minitest::Reporters.use! [Minitest::Reporters::RakeRerunReporter.new(reporter_options)]

require_relative './support/helpers'
