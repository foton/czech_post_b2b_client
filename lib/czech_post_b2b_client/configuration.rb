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
                  :custom_card_number,
                  :log_messages_at_least_as

    def initialize
      # set defaults here

      # ours, accessible, but maybe out of date, for test usage
      @namespaces = {
        'xmlns' => 'https://b2b.postaonline.cz/schema/B2BCommon-v1',
        'xmlns:ns2' => 'https://b2b.postaonline.cz/schema/POLServices-v1',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:noNamespaceSchemaLocation' => 'https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/documents/latest_xsds/B2BCommon.xsd',
        'xsi:schemaLocation' => 'https://b2b.postaonline.cz/schema/POLServices-v1 https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/documents/latest_xsds/B2BPOLServices.xsd'
      }

      @language = :cs
      @logger = defined?(Rails::Logger) ? ::Rails.logger : ::Logger.new($stdout)
      @b2b_api_base_uri = 'https://b2b.postaonline.cz/services/POLService/v1'
      @sending_post_office_location_number = 1

      # set this to :error in production for API debug logs in production.log
      @log_messages_at_least_as = :debug # so all logs keeps their level
    end
  end
end
