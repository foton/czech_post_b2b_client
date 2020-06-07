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
                  :b2b_api_base_uri,
                  :print_options,
                  :custom_card_number

    def initialize
      # set defaults here

      # ours, accessible, but maybe out of date, for test usage
      @namespaces = {
        'xmlns' => 'https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/documents/B2B_CP_POL_2020-05-21/B2BCommon-v1.1.xsd',
        'xmlns:ns2' => 'https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/documents/B2B_CP_POL_2020-05-21/B2B-POLServices-v1.8.xsd'
      }
      # original, accessible only with setup certificates
      @namespaces = {
        'xmlns' => 'https://b2b.postaonline.cz/schema/B2BCommon-v1',
        'xmlns:ns2' => 'https://b2b.postaonline.cz/schema/POLServices-v1'
      }
      @language = :cs
      @logger = defined?(Rails) ? ::Rails.logger : ::Logger.new(STDOUT)
      @b2b_api_base_uri = 'https://b2b.postaonline.cz/services/POLService/v1'
      @sending_post_office_location_number = 1
    end
  end
end
