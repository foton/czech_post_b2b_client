# frozen_string_literal: true

require 'test_helper'


module CzechPostB2bClient
  module Test
    class IntegrationTest < Minitest::Test
      def setup
        stub_api_calls
      end

      def test_it_have_successfull_workflow
        skip
        it_imports_parcels_data
        it_collect_results_of_import
        it_prints_address_sheets
        it_closes_submission_batch
        it_checks_delivery_statuses
        it_knows_statistics
      end

      def it_imports_parcels_data
        # post informations about parcels to Czech Post
        sender_service = ParcelsSender.call(sending_data: sending_data, parcels: parcels)
        processing_end_time = sender_service.result.processing_end_time
        transmission_id = sender_service.result.transmission_id
      end

      def it_collect_results_of_import
        wait_until(processing_end_time)
        inspector_service = ParcelsSendProcessUpdater.call(transmission_id, parcels)
        unless inspector_service.success?
          wait_until(Time.zone.now + 60)
          inspector_service = ParcelsSendProcessUpdater.call(transmission_id, parcels)
        end
        # parcels have assigned `code` and `sending_status`
      end

      def it_prints_address_sheets
        pdf_service = AddressSheetsGenerator.call(parcels, format: '4x2')
        pdf_file_content = pdf_service.result if pdf_service.success?
      end

      def it_closes_submission_batch
        # close submission before delivering parcels to post office
        raise 'Not closed!' unless ParcelsSubmissionCloser.call.success?
      end

      def it_checks_delivery_statuses
        refute parcel_1of2.delivered?
        refute parcel_2of2.delivered?
        refute parcel_3.delivered?
        deliver_inspector = DeliveringInspector.call(parcels)
        # will update `parcel.current_state`, `parcel.last_state_change` and `parcel.state_changes`.
        assert parcel_1of2.delivered?
        assert parcel_2of2.delivered?
        refute parcel_3.delivered?

        assert_equal 3, parcel1.state_changes.size
        assert_equal :delivered, parcel1.state_changes.to_state
        assert_equal p1_deliver_time, parcel1.state_changes.changed_at
      end

      def it_knows_statistics
        statisticator = PeriodStatisticator.call(from: date_from, to: date_to)
        expected_stats = { imports_ok: 1, imports_failed: 0, parcels_processed: 2 }
        assert_equal expected_stats, statisticator.result
      end

      private

      def parcels
        @parcels ||= [parcel_1of2, parcel_2of2, parcel_3]
      end

      def parcel_1of2
        @parcel_1of2 ||= CzechPostB2bClient::Parcel.new(id: 'package_1',
                                                        parcel_code_prefix: 'BA',
                                                        adressee: full_addressee_data,
                                                        weight_in_kg: 12_345.678,
                                                        parcel_order: 1,
                                                        parcels_count: 2)
      end

      def parcel_2of2
        @parcel_2of2 ||= CzechPostB2bClient::Parcel.new(id: 'package_2',
                                                        parcel_code_prefix: 'BA',
                                                        adressee: full_addressee_data,
                                                        weight_in_kg: 345.678,
                                                        parcel_order: 2,
                                                        parcels_count: 2)
      end

      def parcel_3
        @parcel3 ||= CzechPostB2bClient::Parcel.new(id: 'package_3',
                                                    parcel_code_prefix: 'RR',
                                                    adressee: short_addressee_data)
      end

      def stub_api_calls
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
    end
  end
end
