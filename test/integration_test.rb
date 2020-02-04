# frozen_string_literal: true

require 'test_helper'


module CzechPostB2bClient
  module Test
    class IntegrationTest < Minitest::Test
      attr_accessor :processing_end_time, :transaction_id, :parcels
      attr_reader :expected_processing_end_time, :expected_transaction_id

      def setup
        setup_configuration
        @parcels = [parcel_1of2, parcel_2of2, parcel_3]
        @expected_processing_end_time = (Time.now + 4) # + 4 seconds
        @expected_transaction_id = 'string50'

        stub_api_calls
      end

      def test_it_have_successfull_workflow
        it_imports_parcels_data
        skip
        it_collect_results_of_import
        it_prints_address_sheets # and stick it on right parcels
        it_closes_submission_batch
        # here comes the human part: these parcels to post office
        it_checks_delivery_statuses
        it_knows_statistics
      end

      def it_imports_parcels_data
        # post informations about parcels to Czech Post
        sender_service = CzechPostB2bClient::Services::ParcelsSender.call(sending_data: sending_data, parcels: parcels)

        assert sender_service.success?, "It failed with errors: #{sender_service.errors}"

        @processing_end_time = sender_service.result.processing_end_expected_at
        @transaction_id = sender_service.result.transaction_id

        assert_equal expected_processing_end_time.to_i, processing_end_time.to_i
        assert_equal expected_transaction_id, transaction_id
      end

      def it_collect_results_of_import
        wait_until(processing_end_time)
        inspector_service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id)
        unless inspector_service.success?
          wait_until(Time.zone.now + 60)
          inspector_service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id)
        end
        update_parcels_data_with(inspector_service.result) # TODO: parcels have assigned `code` and `sending_status`
      end

      def it_prints_address_sheets
        pdf_service = CzechPostB2bClient::Services::AddressSheetsGenerator.call(parcels, format: '4x2')

        assert pdf_service.success?

        pdf_file_content = pdf_service.result
        save_as_pdf(pdf_file_content)
      end

      def it_closes_submission_batch
        # close submission before delivering parcels to post office
        raise 'Not closed!' unless CzechPostB2bClient::Services::ParcelsSubmissionCloser.call.success?
      end

      def it_checks_delivery_statuses
        refute parcel_1of2.delivered?
        refute parcel_2of2.delivered?
        refute parcel_3.delivered?

        deliver_inspector = CzechPostB2bClient::Services::DeliveringInspector.call(parcels)

        assert deliver_inspector.success?

        # will update `parcel.current_state`, `parcel.last_state_change` and `parcel.state_changes`.
        assert parcel_1of2.delivered?
        assert parcel_2of2.delivered?
        refute parcel_3.delivered?

        assert_equal 3, parcel1.state_changes.size
        assert_equal :delivered, parcel1.state_changes.to_state
        assert_equal p1_deliver_time, parcel1.state_changes.changed_at
      end

      def it_knows_statistics
        statisticator = CzechPostB2bClient::Services::TimePeriodStatisticator.call(from: date_from, to: date_to)
        expected_stats = { imports_ok: 1, imports_failed: 0, parcels_processed: 2 }
        assert_equal expected_stats, statisticator.result
      end

      private

      def parcel_1of2
        @parcel_1of2 ||= {
          params: { parcel_id: 'package_1',
                    parcel_code_prefix: 'BA',
                    adressee: full_addressee_data,
                    weight_in_kg: 12_345.678,
                    parcel_order: 1,
                    parcels_count: 2 }
        }
      end

      def parcel_2of2
        @parcel_2of2 ||= {
          params: { parcel_id: 'package_2',
                    parcel_code_prefix: 'BA',
                    adressee: full_addressee_data,
                    weight_in_kg: 345.678,
                    parcel_order: 2,
                    parcels_count: 2 }
          }
      end

      def parcel_3
        @parcel_3 ||= {
          params: { parcel_id: 'package_3',
                    parcel_code_prefix: 'RR',
                    adressee: short_addressee_data }
          }
      end

      def stub_api_calls

        stub_request(:post, 'https://b2b.postaonline.cz/services/POLService/v1/sendParcels')
          .to_return(status: 200, body: send_parcels_response_xml, headers: {})

        # TODO
        # sendParcels
        # getResultParcels
        # getParcelsPrinting
        # getParcelState
        # getStats
      end

      def sending_data
        sd = full_common_data.dup
        sd.delete(:customer_id) # taken from config
        sd.delete(:sending_post_office_code) # taken from config
        sd
      end

      def send_parcels_response_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <v1:b2bASyncResponse xmlns:v1="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:v1_1="https://b2b.postaonline.cz/schema/POLServices-v1">
            <v1:header>
              <v1:idTransaction>#{expected_transaction_id}</v1:idTransaction> <!-- ID B2B, které unikátní, k použití v getResultParcels -->
              <v1:timeStamp>2016-02-25T08:30:03.678Z</v1:timeStamp>
              <v1:timeStampProcessing>#{expected_processing_end_time.strftime('%FT%T.%L%:z')}</v1:timeStampProcessing> <!-- Předpokládaný čas zpracování backendem -->
              <v1:b2bRequestHeader>
                <v1:idExtTransaction>42</v1:idExtTransaction>
                <v1:timeStamp>2014-03-12T12:33:34.573Z</v1:timeStamp>
                <v1:idContract>#{configuration.contract_id}</v1:idContract>
              </v1:b2bRequestHeader>
            </v1:header>
          </v1:b2bASyncResponse>
        XML
      end
    end
  end
end
