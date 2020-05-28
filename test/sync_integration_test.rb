# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class SyncIntegrationTest < Minitest::Test # rubocop:disable Metrics/ClassLength
      attr_accessor :parcels
      attr_reader :parcel_expected_code, :parcel_codes

      def setup
        setup_configuration

        @parcels = [parcel]
        @parcel_expected_code = 'RR1010101012B'
        @parcel_codes = [@parcel_expected_code]

        stub_api_calls
      end

      def test_it_have_successfull_workflow
        it_imports_parcel_data_and_get_result_with_print
        # here comes the human part: these parcels to post office
        it_checks_delivery_statuses
        it_knows_statistics
      end

      def it_imports_parcel_data_and_get_result_with_print
        # post informations about parcels to Czech Post
        sender_service = CzechPostB2bClient::Services::ParcelsSyncSender.call(sending_data: sending_data,
                                                                              parcels: parcels)

        assert sender_service.success?, "ParcelSyncSender failed with errors: #{sender_service.errors}"

        update_parcels_data_with(sender_service.result.parcels_hash)

        assert_equal parcel_expected_code, parcel[:parcel_code]
        save_as_pdf(parcel[:pdf_content])
      end

      def it_checks_delivery_statuses # rubocop:disable Metrics/AbcSize
        refute parcel[:delivered]

        delivering_inspector = CzechPostB2bClient::Services::DeliveringInspector.call(parcel_codes: parcel_codes)

        assert delivering_inspector.success?, "DeliveringInspector failed with errors: #{delivering_inspector.errors}"

        # will update `parcel.current_state`, `parcel.last_state_change` and `parcel.state_changes`.
        update_parcels_states_with(delivering_inspector.result)

        assert parcel[:delivered]

        assert_equal 7, parcel[:state_changes].size
        assert_equal '91', parcel[:current_state][:id] # delivered
      end

      def it_knows_statistics
        statisticator = CzechPostB2bClient::Services::TimePeriodStatisticator.call(from_date: Date.new(2019, 10, 23),
                                                                                   to_date: Date.new(2020, 2, 2))
        stats = statisticator.result

        assert_equal 16, stats.requests.total
        assert_equal 13, stats.requests.with_errors
        assert_equal 3, stats.requests.successful
        assert_equal 43, stats.imported_parcels
      end

      private

      def parcel
        @parcel ||= {
          addressee: short_addressee_data,
          params: { parcel_id: 'package_3',
                    parcel_code_prefix: 'RR' }
        }
      end

      def stub_api_calls
        stub_request(:post, 'https://b2b.postaonline.cz/services/POLService/v1/parcelServiceSync')
          .to_return(status: 200, body: parcel_service_sync_response_xml, headers: {})

        stub_request(:post, 'https://b2b.postaonline.cz/services/POLService/v1/getParcelState')
          .to_return(status: 200, body: get_parcel_state_response_xml, headers: {})

        stub_request(:post, 'https://b2b.postaonline.cz/services/POLService/v1/getStats')
          .to_return(status: 200, body: get_stats_response_xml, headers: {})
      end

      def sending_data
        sd = full_common_data.dup
        sd.delete(:customer_id) # taken from config
        sd.delete(:sending_post_office_code) # taken from config
        sd[:print_params] = { template_id: 21,
                              margin_in_mm: { top: 2, left: 1 },
                              position_order: 3 }
        sd
      end

      def save_as_pdf(pdf_content)
        # do printing or saving here
      end

      def update_parcels_data_with(updated_parcels_hash)
        parcels.each do |parcel|
          parcel[:parcel_code] = updated_parcels_hash[parcel[:params][:parcel_id]][:parcel_code]
        end
      end

      def update_parcels_states_with(states_hash)
        parcels.each do |parcel|
          parcel_hash = states_hash[parcel[:parcel_code]]
          next if parcel_hash.nil?

          parcel[:current_state] = parcel_hash[:current_state]
          parcel[:state_changes] = parcel_hash[:all_states]
          parcel[:delivered] = parcel_hash[:current_state][:id] == '91'
        end
      end

      def parcel_service_sync_response_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <v1:b2bSyncResponse xmlns:v1="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:v1_1="https://b2b.postaonline.cz/schema/POLServices-v1">
            <v1:header>
              <v1:timeStamp>2016-02-25T08:30:03.678Z</v1:timeStamp>
              <v1:b2bRequestHeader>
                <v1:idExtTransaction>42</v1:idExtTransaction>
                <v1:timeStamp>2014-03-12T12:33:34.573Z</v1:timeStamp>
                <v1:idContract>#{configuration.contract_id}</v1:idContract>
              </v1:b2bRequestHeader>
            </v1:header>
            <v1:serviceData>
              <v1_1:parcelServiceSyncResponse>
                <v1_1:responseHeader>
                  <v1_1:resultHeader>
                    <v1_1:responseCode>1</v1_1:responseCode>
                    <v1_1:responseText>OK</v1_1:responseText>
                  </v1_1:resultHeader>
                  <v1_1:resultParcelData>
                    <v1_1:recordNumber>#{parcel[:params][:parcel_id]}</v1_1:recordNumber>
                    <v1_1:parcelCode>#{parcel_expected_code}</v1_1:parcelCode>
                    <v1_1:parcelDataResponse>
                      <v1_1:responseCode>408</v1_1:responseCode>
                      <v1_1:responseText>INFO_ADDRESS_WAS_MODIFIED</v1_1:responseText>
                    </v1_1:parcelDataResponse>
                  </v1_1:resultParcelData>
                </v1_1:responseHeader>
                <v1_1:responsePrintParams>
                  <v1_1:file>dmVyeSBiaWcgcGRmIGV4dHJhY3RlZCBmcm9tIGJhc2U2NCBzdHJpbmc=</v1_1:file>
                  <v1_1:printParamsResponse>
                    <v1_1:responseCode>1</v1_1:responseCode>
                    <v1_1:responseText>OK</v1_1:responseText>
                  </v1_1:printParamsResponse>
                </v1_1:responsePrintParams>
              </v1_1:parcelServiceSyncResponse>
            </v1:serviceData>
          </v1:b2bSyncResponse>
        XML
      end

      def get_parcel_state_response_xml # rubocop:disable Naming/AccessorMethodName
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <v1:b2bSyncResponse xmlns:v1="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:v1_1="https://b2b.postaonline.cz/schema/POLServices-v1">
            <v1:header>
              <v1:timeStamp>2016-02-18T16:00:34.913Z</v1:timeStamp>
              <v1:b2bRequestHeader>
                <v1:idExtTransaction>64</v1:idExtTransaction>
                <v1:timeStamp>2016-03-12T10:00:34.573Z</v1:timeStamp>
                <v1:idContract>25195667001</v1:idContract>
              </v1:b2bRequestHeader>
            </v1:header>
            <v1:serviceData>
              <v1_1:getParcelStateResponse>
                <v1_1:parcel>
                  <v1_1:idParcel>#{parcel_expected_code}</v1_1:idParcel>
                  <v1_1:parcelType>BA</v1_1:parcelType> <!-- string, what is allowed here?! -->
                  <v1_1:states>
                    <v1_1:state>
                      <v1_1:id>21</v1_1:id> <!-- string, what is allowed here?! -->
                      <v1_1:date>2015-09-02</v1_1:date>
                      <v1_1:text>Podání zásilky.</v1_1:text>
                      <v1_1:postCode>26701</v1_1:postCode> <!-- PSC kde stav nastal -->
                      <v1_1:name>Králův Dvůr u Berouna</v1_1:name> <!-- nazev provozovny kde stav nastal -->
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-F</v1_1:id>
                      <v1_1:date>2015-09-03</v1_1:date>
                      <v1_1:text>Vstup zásilky na SPU.</v1_1:text>
                      <v1_1:postCode>22200</v1_1:postCode>
                      <v1_1:name>SPU Praha 022</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-I</v1_1:id>
                      <v1_1:date>2015-09-03</v1_1:date>
                      <v1_1:text>Výstup zásilky z SPU.</v1_1:text>
                      <v1_1:postCode>22200</v1_1:postCode>
                      <v1_1:name>SPU Praha 022</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-B</v1_1:id>
                      <v1_1:date>2015-09-03</v1_1:date>
                      <v1_1:text>Přeprava zásilky k dodací poště.</v1_1:text>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>51</v1_1:id>
                      <v1_1:date>2015-09-04</v1_1:date>
                      <v1_1:text>Příprava zásilky k doručení.</v1_1:text>
                      <v1_1:postCode>25607</v1_1:postCode>
                      <v1_1:name>Depo Benešov 70</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>53</v1_1:id>
                      <v1_1:date>2015-09-04</v1_1:date>
                      <v1_1:text>Doručování zásilky.</v1_1:text>
                      <v1_1:postCode>25756</v1_1:postCode>
                      <v1_1:name>Neveklov</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>91</v1_1:id>
                      <v1_1:date>2015-09-04</v1_1:date>
                      <v1_1:text>Dodání zásilky.</v1_1:text>
                      <v1_1:postCode>25756</v1_1:postCode>
                      <v1_1:name>Neveklov</v1_1:name>
                    </v1_1:state>
                  </v1_1:states>
                </v1_1:parcel>
              </v1_1:getParcelStateResponse>
            </v1:serviceData>
          </v1:b2bSyncResponse>
        XML
      end

      def get_stats_response_xml # rubocop:disable Naming/AccessorMethodName
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <v1:b2bSyncResponse xmlns:v1="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:v1_1="https://b2b.postaonline.cz/schema/POLServices-v1">
            <v1:header>
              <v1:timeStamp>2016-02-25T08:30:03.678Z</v1:timeStamp>
              <v1:b2bRequestHeader>
                <v1:idExtTransaction>42</v1:idExtTransaction>
                <v1:timeStamp>2014-03-12T12:33:34.573Z</v1:timeStamp>
                <v1:idContract>25195667001</v1:idContract>
              </v1:b2bRequestHeader>
            </v1:header>
            <v1:serviceData>
              <v1_1:getStatsResponse>
                <v1_1:importAll>16</v1_1:importAll>
                <v1_1:importErr>13</v1_1:importErr>
                <v1_1:importOk>3</v1_1:importOk>
                <v1_1:parcels>43</v1_1:parcels>
              </v1_1:getStatsResponse>
            </v1:serviceData>
          </v1:b2bSyncResponse>
        XML
      end
    end
  end
end
