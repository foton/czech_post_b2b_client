# frozen_string_literal: true

module CzechPostB2bClient
  class Configuration
    attr_accessor :contract_id, :path_from_root_to_certificate, :namespaces, :language

    def initialize
      # set defaults here

      # ours, accessible, but maybe oout of date
      @namespaces = { 'xmlns' => 'https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/doc/20181023/B2BCommon-v1.1.xsd',
                      'xmlns:ns2' => 'https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/doc/20181023/B2B-POLServices-v1.6.xsd' }
      # original, not functioning
      @namespaces = { 'xmlns' => 'https://b2b.postaonline.cz/schema/B2BCommon-v1',
                      'xmlns:ns2' => 'https://b2b.postaonline.cz/schema/POLServices-v1' }
      @language = :cs
    end
  end
end
