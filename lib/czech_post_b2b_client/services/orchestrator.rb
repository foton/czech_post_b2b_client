# frozen_string_literal: true

module CzechPostB2bClient
  module Services
    class Orchestrator < SteppedService::Base
      private

      def result_of_subservice(service_hash)
        service_name = service_hash.keys.first
        service_class = send("#{service_name}_class")
        service = service_class.call(service_hash.values.first)

        if service.failed?
          errors.add_from_hash({ service_name => service.errors.full_messages })
          fail!
        end

        service.result
      end

      def configuration
        CzechPostB2bClient.configuration
      end
    end
  end
end
