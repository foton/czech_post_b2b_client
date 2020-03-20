# frozen_string_literal: true

require 'logger'

module CzechPostB2bClient
  class Configuration
    attr_accessor :customer_id,
                  :contract_id,
                  :sending_post_office_code,
                  :sending_post_office_location_number,
                  :certificate_path,
                  :private_key_password,
                  :private_key_path,
                  :namespaces,
                  :language,
                  :logger,
                  :b2b_api_base_uri

    def initialize
      # set defaults here

      # ours, accessible, but maybe oout of date
      @namespaces = { 'xmlns' => 'https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/doc/20181023/B2BCommon-v1.1.xsd',
                      'xmlns:ns2' => 'https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/doc/20181023/B2B-POLServices-v1.6.xsd' }
      # original, not functioning
      @namespaces = { 'xmlns' => 'https://b2b.postaonline.cz/schema/B2BCommon-v1',
                      'xmlns:ns2' => 'https://b2b.postaonline.cz/schema/POLServices-v1' }
      @language = :cs
      @logger = defined?(Rails) ? ::Rails.logger : ::Logger.new(STDOUT)
      @b2b_api_base_uri = 'https://b2b.postaonline.cz/services/POLService/v1'
      @sending_post_office_location_number = 1
    end
  end
end
