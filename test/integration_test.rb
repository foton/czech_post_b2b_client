# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class IntegrationTest < Minitest::Test
      attr_accessor :processing_end_time, :transaction_id, :parcels
      attr_reader :expected_processing_end_time,
                  :expected_transaction_id,
                  :parcel_1of2_expected_code,
                  :parcel_2of2_expected_code,
                  :parcel_3_expected_code,
                  :parcel_codes,
                  :expected_first_state_change_of_parcel_1of2

      def setup
        setup_configuration
        @parcels = [parcel_1of2, parcel_2of2, parcel_3]
        @expected_processing_end_time = (Time.now + 4) # + 4 seconds
        @expected_transaction_id = 'string50'
        @parcel_1of2_expected_code = 'BA1010101010B'
        @parcel_2of2_expected_code = 'BA1010101011B'
        @parcel_3_expected_code = 'RR1010101012B'
        @parcel_codes = [@parcel_1of2_expected_code, @parcel_2of2_expected_code, @parcel_3_expected_code]
        @expected_first_state_change_of_parcel_1of2 = { id: '21',
                                                        date: Date.new(2015, 9, 2),
                                                        text: 'Podání zásilky.',
                                                        post_code: '26701',
                                                        post_name: 'Králův Dvůr u Berouna' }

        stub_api_calls
      end

      def test_it_have_successfull_workflow
        it_imports_parcels_data
        it_collect_results_of_import
        it_prints_address_sheets # and stick it on right parcels
        it_closes_submission_batch
        # here comes the human part: these parcels to post office
        it_checks_delivery_statuses
        skip
        it_knows_statistics
      end

      def it_imports_parcels_data
        # post informations about parcels to Czech Post
        sender_service = CzechPostB2bClient::Services::ParcelsSender.call(sending_data: sending_data, parcels: parcels)

        assert sender_service.success?, "ParcelSender failed with errors: #{sender_service.errors}"

        @processing_end_time = sender_service.result.processing_end_expected_at
        @transaction_id = sender_service.result.transaction_id

        assert_equal expected_processing_end_time.to_i, processing_end_time.to_i
        assert_equal expected_transaction_id, transaction_id
      end

      def it_collect_results_of_import
        wait_until(processing_end_time)
        inspector_service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id: transaction_id)
        unless inspector_service.success?
          wait_until(Time.zone.now + 60)
          inspector_service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id: transaction_id)
        end

        assert inspector_service.success?, "ParcelsSendProcessUpdater failed with errors: #{inspector_service.errors}"

        update_parcels_data_with(inspector_service.result.parcels_hash) # TODO: parcels have assigned `code` and `sending_status`

        assert_equal parcel_1of2_expected_code, parcel_1of2[:parcel_code]
        assert_equal parcel_2of2_expected_code, parcel_2of2[:parcel_code]
        assert_equal parcel_3_expected_code, parcel_3[:parcel_code]
      end

      def it_prints_address_sheets
        options = {
          customer_id: configuration.customer_id, # required
          contract_number: configuration.contract_id, # not required
          template_id: 24, # 'obalka 3 - B4'   : not required
          margin_in_mm: { top: 5, left: 3 } # required
        }

        pdf_service = CzechPostB2bClient::Services::AddressSheetsGenerator.call(parcel_codes: parcel_codes, options: options )

        assert pdf_service.success?, "AddressSheetGenerator failed with errors: #{pdf_service.errors}"

        pdf_file_content = pdf_service.result
        save_as_pdf(pdf_file_content)
      end

      def it_closes_submission_batch
        # close submission before delivering parcels to post office
        closer_service = CzechPostB2bClient::Services::ParcelsSubmissionCloser.call(sending_data: sending_data)
        assert closer_service.success?, "ParcelsSubmissionCloser failed with errors: #{closer_service.errors}"
      end

      def it_checks_delivery_statuses
        refute parcel_1of2[:delivered]
        refute parcel_2of2[:delivered]
        refute parcel_3[:delivered]

        delivering_inspector = CzechPostB2bClient::Services::DeliveringInspector.call(parcel_codes: parcel_codes)

        assert delivering_inspector.success?, "DeliveringInspector failed with errors: #{delivering_inspector.errors}"

        # will update `parcel.current_state`, `parcel.last_state_change` and `parcel.state_changes`.
        update_parcels_states_with(delivering_inspector.result)

        assert parcel_1of2[:delivered]
        assert parcel_2of2[:delivered]
        refute parcel_3[:delivered]

        assert_equal 7, parcel_1of2[:state_changes].size
        assert_equal '91', parcel_1of2[:current_state][:id] # delivered
        assert_equal expected_first_state_change_of_parcel_1of2, parcel_1of2[:state_changes].first

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

        stub_request(:post, "https://b2b.postaonline.cz/services/POLService/v1/getResultParcels")
          .to_return(status: 200, body: get_result_parcels_response_xml, headers: {})

        stub_request(:post, "https://b2b.postaonline.cz/services/POLService/v1/getParcelsPrinting")
          .to_return(status: 200, body: get_parcels_printing_response_xml, headers: {})

        # ParcelsSubmissionCloser uses same stub as ParcelSender (it actualy call the same service URL)

        stub_request(:post, "https://b2b.postaonline.cz/services/POLService/v1/getParcelState")
          .to_return(status: 200, body: get_parcel_state_response_xml, headers: {})

        # getStats
      end

      def sending_data
        sd = full_common_data.dup
        sd.delete(:customer_id) # taken from config
        sd.delete(:sending_post_office_code) # taken from config
        sd
      end

      def wait_until(time)
        # this is just usage example
        # no need to wait in tests
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

      def get_result_parcels_response_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <p:b2bSyncResponse xmlns:p="https://b2b.postaonline.cz/schema/B2BCommon-v1" xmlns:PO="https://b2b.postaonline.cz/schema/POLServices-v1">
            <p:header>
              <p:timeStamp>2016-02-18T16:00:34.913Z</p:timeStamp>
              <p:b2bRequestHeader>
                <p:idExtTransaction>64</p:idExtTransaction>
                <p:timeStamp>2016-03-12T10:00:34.573Z</p:timeStamp>
                <p:idContract>25195667001</p:idContract>
              </p:b2bRequestHeader>
            </p:header>
            <p:serviceData>
              <PO:getResultParcelsResponse>
                <PO:doParcelHeaderResult>
                  <PO:doParcelStateResponse>  <!-- I do not understand meaning of this -->
                    <PO:responseCode>1</PO:responseCode>
                    <PO:responseText>OK</PO:responseText>
                  </PO:doParcelStateResponse>
                </PO:doParcelHeaderResult>

                <PO:doParcelParamResult>
                  <!-- my guess: sendParcels.doParcelData.doParcelParams.recordID == recordNumber -->
                  <PO:recordNumber>#{parcel_1of2[:params][:parcel_id]}</PO:recordNumber> <!-- unique ID of record, string,-->
                  <PO:parcelCode>#{parcel_1of2_expected_code}</PO:parcelCode>
                  <PO:doParcelStateResponse>   <!-- according to XSD, there is unlimited count of this! -->
                    <PO:responseCode>1</PO:responseCode>
                    <PO:responseText>OK</PO:responseText>
                  </PO:doParcelStateResponse>
                </PO:doParcelParamResult>

                <PO:doParcelParamResult>
                   <!-- I am not yet sure if, packages of one parcels shares same code -->
                  <PO:recordNumber>#{parcel_2of2[:params][:parcel_id]}</PO:recordNumber>
                  <PO:parcelCode>#{parcel_2of2_expected_code}</PO:parcelCode>
                  <PO:doParcelStateResponse>
                    <PO:responseCode>1</PO:responseCode>
                    <PO:responseText>OK</PO:responseText>
                  </PO:doParcelStateResponse>
                </PO:doParcelParamResult>

                <PO:doParcelParamResult>
                  <PO:recordNumber>#{parcel_3[:params][:parcel_id]}</PO:recordNumber>
                  <PO:parcelCode>#{parcel_3_expected_code}</PO:parcelCode>
                  <PO:doParcelStateResponse>
                    <PO:responseCode>1</PO:responseCode>
                    <PO:responseText>OK</PO:responseText>
                  </PO:doParcelStateResponse>
                </PO:doParcelParamResult>

              </PO:getResultParcelsResponse>
            </p:serviceData>
          </p:b2bSyncResponse>
        XML
      end

      def get_parcels_printing_response_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <b2bSyncResponse xmlns="https://b2b.postaonline.cz/schema/B2BCommon-v1"
            xmlns:ns2="https://b2b.postaonline.cz/schema/POLServices-v1">
            <header>
              <timeStamp>2016-02-18T16:00:34.913Z</timeStamp>
              <b2bRequestHeader>
                <idExtTransaction>42</idExtTransaction>
                <timeStamp>2016-03-12T10:00:34.573Z</timeStamp>
                <idContract>25195667001</idContract>
              </b2bRequestHeader>
            </header>
            <serviceData>
              <ns2:getParcelsPrintingResponse>
                <ns2:doPrintingHeaderResult>
                  <ns2:doPrintingHeader>
                    <ns2:customerID>#{configuration.customer_id}</ns2:customerID>
                    <ns2:contractNumber>#{configuration.contract_id}</ns2:contractNumber>
                    <ns2:idForm>24</ns2:idForm>
                    <ns2:shiftHorizontal>3</ns2:shiftHorizontal>
                    <ns2:shiftVertical>5</ns2:shiftVertical>
                    <ns2:position>1</ns2:position>
                  </ns2:doPrintingHeader>
                  <ns2:doPrintingStateResponse>
                    <ns2:responseCode>0</ns2:responseCode>
                    <ns2:responseText>OK</ns2:responseText>
                  </ns2:doPrintingStateResponse>
                </ns2:doPrintingHeaderResult>
                <ns2:doPrintingDataResult>
                  <ns2:file>dmVyeSBiaWcgcGRmIGV4dHJhY3RlZCBmcm9tIGJhc2U2NCBzdHJpbmc=</ns2:file>
                </ns2:doPrintingDataResult>
              </ns2:getParcelsPrintingResponse>
            </serviceData>
          </b2bSyncResponse>
        XML
      end

      def get_parcel_state_response_xml
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
                  <v1_1:idParcel>#{parcel_1of2_expected_code}</v1_1:idParcel>
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
                <v1_1:parcel>
                  <v1_1:idParcel>#{parcel_2of2_expected_code}</v1_1:idParcel>
                  <v1_1:parcelType>BA</v1_1:parcelType>
                  <v1_1:weight>0.686</v1_1:weight>
                  <v1_1:amount>0</v1_1:amount>
                  <v1_1:currency></v1_1:currency>
                  <v1_1:timeDeposit>15</v1_1:timeDeposit>
                  <v1_1:states>
                    <v1_1:state>
                      <v1_1:id>21</v1_1:id>
                      <v1_1:date>2015-08-18</v1_1:date>
                      <v1_1:text>Podání zásilky.</v1_1:text>
                      <v1_1:postCode>53703</v1_1:postCode>
                      <v1_1:name>Chrudim 3</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-F</v1_1:id>
                      <v1_1:date>2015-08-18</v1_1:date>
                      <v1_1:text>Vstup zásilky na SPU.</v1_1:text>
                      <v1_1:postCode>53020</v1_1:postCode>
                      <v1_1:name>SPU Pardubice 02</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-I</v1_1:id>
                      <v1_1:date>2015-08-19</v1_1:date>
                      <v1_1:text>Výstup zásilky z SPU.</v1_1:text>
                      <v1_1:postCode>22200</v1_1:postCode>
                      <v1_1:name>SPU Praha 022</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-B</v1_1:id>
                      <v1_1:date>2015-08-19</v1_1:date>
                      <v1_1:text>Přeprava zásilky k dodací poště.</v1_1:text>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>51</v1_1:id>
                      <v1_1:date>2015-08-20</v1_1:date>
                      <v1_1:text>Příprava zásilky k doručení.</v1_1:text>
                      <v1_1:postCode>25607</v1_1:postCode>
                      <v1_1:name>Depo Benešov 70</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>53</v1_1:id>
                      <v1_1:date>2015-08-20</v1_1:date>
                      <v1_1:text>Doručování zásilky.</v1_1:text>
                      <v1_1:postCode>25756</v1_1:postCode>
                      <v1_1:name>Neveklov</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>43</v1_1:id>
                      <v1_1:date>2015-08-20</v1_1:date>
                      <v1_1:text>E-mail odesílateli - dodání zásilky.</v1_1:text>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>91</v1_1:id>
                      <v1_1:date>2015-08-20</v1_1:date>
                      <v1_1:text>Dodání zásilky.</v1_1:text>
                      <v1_1:postCode>25756</v1_1:postCode>
                      <v1_1:name>Neveklov</v1_1:name>
                    </v1_1:state>
                  </v1_1:states>
                </v1_1:parcel>
                <v1_1:parcel>
                  <v1_1:idParcel>#{parcel_3_expected_code}</v1_1:idParcel>
                  <v1_1:parcelType>RR</v1_1:parcelType>
                  <v1_1:weight>0.086</v1_1:weight>
                  <v1_1:amount>0</v1_1:amount>
                  <v1_1:currency></v1_1:currency>
                  <v1_1:timeDeposit>15</v1_1:timeDeposit>
                  <v1_1:states>
                    <v1_1:state>
                      <v1_1:id>21</v1_1:id>
                      <v1_1:date>2015-08-18</v1_1:date>
                      <v1_1:text>Podání zásilky.</v1_1:text>
                      <v1_1:postCode>53703</v1_1:postCode>
                      <v1_1:name>Chrudim 3</v1_1:name>
                    </v1_1:state>
                    <v1_1:state>
                      <v1_1:id>-F</v1_1:id>
                      <v1_1:date>2015-08-18</v1_1:date>
                      <v1_1:text>Vstup zásilky na SPU.</v1_1:text>
                      <v1_1:postCode>53020</v1_1:postCode>
                      <v1_1:name>SPU Pardubice 02</v1_1:name>
                    </v1_1:state>
                  </v1_1:states>
                </v1_1:parcel>
              </v1_1:getParcelStateResponse>
            </v1:serviceData>
          </v1:b2bSyncResponse>
        XML
      end
    end
  end
end
