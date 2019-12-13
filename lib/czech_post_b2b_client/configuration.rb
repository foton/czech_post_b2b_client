# frozen_string_literal: true

module CzechPostB2bClient
  class Configuration
    attr_accessor :contract_id, :path_from_root_to_certificate, :namespaces

    def initialize
      # set defaults here
      @namespaces = { 'xmlns' => 'https://b2b.postaonline.cz/schema/B2BCommon-v1',
                      'xmlns:ns2' => 'https://b2b.postaonline.cz/schema/POLServices-v1' }
    end
  end
end
