# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class ParcelsSender < CzechPostB2bClient::Services::ParcelsAsyncSender
      class << self
        extend Gem::Deprecate
        deprecate :call, 'CzechPostB2bClient::Services::ParcelsAsyncSender.call', 2020, 8
      end
    end
  end
end
