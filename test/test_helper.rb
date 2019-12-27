# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'czech_post_b2b_client'

require 'minitest/autorun'
require 'pry-byebug'

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
