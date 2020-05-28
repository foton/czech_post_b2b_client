# frozen_string_literal: true

# uncomment next row, if You debug cloned gem repo
$LOAD_PATH.unshift File.expand_path('.././lib', __dir__)

require 'czech_post_b2b_client'
require 'time' # to be able Time.parse
require 'pry'

class TryApiCalls # rubocop:disable Metrics/ClassLength
  attr_accessor :configuration, :processing_end_time_utc, :transaction_id, :parcels

  def run
    setup_configuration(config_hash)

    @configuration = CzechPostB2bClient.configuration
    @processing_end_time_utc = nil
    @transaction_id = nil
    import_parcels = :async # :no, :sync, :async

    case import_parcels
    when :async
      @parcels = [parcel_1of2, parcel_2of2, parcel_3]
      async_import_parcels_data
    when :sync
      @parcels = [parcel_3]
      sync_import_parcels_data
    else # eg :no
      # if You skipping IMPORT of parcels and asks for existing records
      @parcels = build_parcels_for(existing_parcel_codes)
    end

    # print_all_template_sheets_for_parcel_codes  # if you need to check available templates for parcel_types

    # prin address sheets and stick it on right parcels
    # sync version get address sheet in response of import
    print_address_sheets(print_options) unless import_parcels == :sync

    ### here comes the human part: these parcels to post office

    check_and_update_delivery_statuses
    find_out_statistics
  end

  def download_xsds
    setup_configuration(config_hash)
    CzechPostB2bClient::Services::XsdsDownloader.call
  end

  private

  # this is all You need to change, to test gem for Your setup
  def config_hash
    certs_path = File.join(__dir__, '..', 'our_certs')

    { contract_id: '356936003', # from CP signed contract
      customer_id: 'L03051', # from CP signed contract
      certificate_path: File.join(certs_path, 'squared_VCA12032726.pem'),
      private_key_password: nil,
      private_key_path: File.join(certs_path, 'squared_private.key'),
      sending_post_office_code: 12_000 }
  end

  def existing_parcel_codes
    # If Import of parcels do not work for You yet,
    # You can insert parcels in Web PodaniOnline and then use this hack to check some services
    %w[BA0305100278L BA0305100264L BA0305100255L]
  end

  def sending_data
    sd = short_common_data.dup
    sd.delete(:customer_id) # taken from config
    sd.delete(:sending_post_office_code) # taken from config
    sd
  end

  def print_options
    {
      customer_id: configuration.customer_id, # required
      contract_number: configuration.contract_id, # not required
      template_id: 40,
      margin_in_mm: { top: 1, left: 1 } # required
    }
  end

  def parcel_1of2
    @parcel_1of2 ||= {
      addressee: short_addressee_data,
      params: { parcel_id: 'package_1of2',
                parcel_code_prefix: 'BA',
                weight_in_kg: 1.0, # BA => max 2.0
                parcel_order: 1,
                parcels_count: 2 },
      services: [70, 7, 'S']
    }
  end

  def parcel_2of2
    @parcel_2of2 ||= {
      addressee: short_addressee_data,
      params: { parcel_id: 'package_2of2',
                parcel_code_prefix: 'BA',
                weight_in_kg: 1.6,
                parcel_order: 2,
                parcels_count: 2 },
      services: [70, 'S']
    }
  end

  def parcel_3
    @parcel_3 ||= {
      addressee: short_addressee_data,
      params: { parcel_id: 'package_3',
                parcel_code_prefix: 'BA',
                weight_in_kg: 1.9 },
      services: [7, 'M']
    }
  end

  def build_parcels_for(parcel_codes)
    parcel_codes.collect do |pcode|
      {
        parcel_code: pcode,
        addressee: 'not set',
        params: { parcel_id: 'ex' + pcode,
                  parcel_code_prefix: pcode[0..1] }
      }
    end
  end

  def parcel_codes
    parcels.collect { |p| p[:parcel_code] }
  end

  def setup_configuration(config_hash = {})
    CzechPostB2bClient.configure do |config|
      config_hash.each_pair do |k, v|
        config.send("#{k}=", v)
      end
    end
  end

  def async_import_parcels_data
    # if you want to skip `import__parcels_data` set this to some real value
    @transaction_id = 'C5064FF7-0171-4000-E000-01360AA0630B'

    import_parcels_data
    while Time.now.utc < (processing_end_time_utc + 1)
      puts("Waiting to #{processing_end_time_utc} (current time is #{Time.now.utc})")
      sleep(1)
    end

    collect_results_of_import
    close_submission_batch
  end

  def sync_import_parcels_data
    # post informations about parcels to Czech Post and get the tracking codes
    send_data = sending_data.merge(print_params: print_options)
    sender_service = CzechPostB2bClient::Services::ParcelsSyncSender.call(sending_data: send_data, parcels: parcels)

    raise "ParcelSyncSender failed with errors: #{sender_service.errors}" unless sender_service.success?

    update_parcels_data_with(sender_service.result.parcels_hash)
    CzechPostB2bClient.logger.debug("[ParcelsSyncSender] => parcels: #{parcels}")
    CzechPostB2bClient.logger.debug("[ParcelsSyncSender] => parcel_codes: #{parcel_codes}")
  end

  def import_parcels_data
    # post informations about parcels to Czech Post
    sender_service = CzechPostB2bClient::Services::ParcelsAsyncSender.call(sending_data: sending_data, parcels: parcels)
    raise "ParcelAsyncSender failed with errors: #{sender_service.errors}" unless sender_service.success?

    # CzechPost returns CET value but marked as UTC zone
    time_in_cet_masked_as_utc = sender_service.result.processing_end_expected_at
    self.processing_end_time_utc = Time.parse(time_in_cet_masked_as_utc.strftime('%F %T')).utc

    self.transaction_id = sender_service.result.transaction_id
    CzechPostB2bClient.logger.debug("[ParcelsAsyncSender] processing_end_time_utc: #{processing_end_time_utc}; transaction_id: #{transaction_id}") # rubocop:disable Layout/LineLength
  end

  def collect_results_of_import
    inspector_service = CzechPostB2bClient::Services::ParcelsSendProcessUpdater.call(transaction_id: transaction_id)
    raise "ParcelsSendProcessUpdater failed with errors: #{inspector_service.errors}" unless inspector_service.success?

    update_parcels_data_with(inspector_service.result.parcels_hash)
    CzechPostB2bClient.logger.debug("[ParcelsSendProcessUpdater] => parcels: #{parcels}")
    CzechPostB2bClient.logger.debug("[ParcelsSendProcessUpdater] => parcel_codes: #{parcel_codes}")
  end

  def print_address_sheets(options, raise_on_failure = true)
    pdf_service = CzechPostB2bClient::Services::AddressSheetsGenerator.call(parcel_codes: parcel_codes,
                                                                            options: options)

    if pdf_service.failure?
      raise "AddressSheetGenerator failed with errors: #{pdf_service.errors}" if raise_on_failure
    else
      save_as_pdf(pdf_service.result.pdf_content, options)
    end
  end

  def print_all_template_sheets_for_parcel_codes
    CzechPostB2bClient::PrintingTemplates.all_classes.each do |t_klass|
      puts("printing #{t_klass}")
      print_address_sheets(print_options.merge(template_id: t_klass.id), false)
      sleep(1)
    end
  end

  def close_submission_batch
    # close submission before delivering parcels to post office
    closer_service = CzechPostB2bClient::Services::ParcelsSubmissionCloser.call(sending_data: sending_data)
    raise "ParcelsSubmissionCloser failed with errors: #{closer_service.errors}" unless closer_service.success?
  end

  def check_and_update_delivery_statuses
    delivering_inspector = CzechPostB2bClient::Services::DeliveringInspector.call(parcel_codes: parcel_codes)

    "DeliveringInspector failed with errors: #{delivering_inspector.errors}" unless delivering_inspector.success?

    # will update `parcel.current_state`, `parcel.last_state_change` and `parcel.state_changes`.
    update_parcels_states_with(delivering_inspector.result)
    CzechPostB2bClient.logger.debug("[DeliveringInspector] =>   parcels: #{parcels}")
  end

  def find_out_statistics
    statisticator = CzechPostB2bClient::Services::TimePeriodStatisticator.call(from_date: Date.today,
                                                                               to_date: Date.today)
    "TimePeriodStatisticator failed with errors: #{statisticator.errors}" unless statisticator.success?
    CzechPostB2bClient.logger.debug("[TimePeriodStatisticator] =>  #{statisticator.result}")
  end

  def save_as_pdf(pdf_content, options)
    def_str = "-template_id_#{options[:template_id]}-"
    def_str += "top_#{options[:margin_in_mm][:top]}-"
    def_str += "left_#{options[:margin_in_mm][:left]}"
    puts('saving:' + def_str)
    prefixes = parcel_codes.collect { |pc| pc[0..1] }
    File.write("#{prefixes.join('_')}#{def_str}.pdf", pdf_content)
  end

  def update_parcels_data_with(updated_parcels_hash)
    # TODO: parcels have assigned `code` and `sending_status`
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

  def short_sender_data
    {
      address: {
        company_name: 'Oriflame',
        addition_to_name: 'perfume', # optional
        street: 'V olšinách',
        house_number: '16',
        city_part: 'Strašnice',
        city: 'Praha',
        post_code: 10_000
      },
      mobile_phone: '+420777888999', # optional
      email: 'rehor.jan@cpost.cz' # optional
    }
  end

  def cod_data
    {
      address: {
        company_name: 'Oriflame',
        addition_to_name: 'perfume2', # optional
        street: 'V olšinách',
        house_number: '16',
        sequence_number: '82',
        city_part: 'Strašnice',
        city: 'Praha',
        post_code: 10_000,
        country_iso_code: 'CZ'
      },
      bank_account: '123456-1234567890/1234'
    }
  end

  def short_common_data
    {
      contract_id: configuration.contract_id,
      customer_id: 'U219',
      parcels_sending_date: Date.today,
      sending_post_office_code: 12_000,
      sending_post_office_location_number: 1, # fotonova 12000
      sender: short_sender_data, # optional?, from config?
      cash_on_delivery: cod_data
    }
  end

  def short_addressee_data
    # all items optional?!
    { address: {
      first_name: 'Petr',
      last_name: 'Foton',
      street: 'Fischerova',
      house_number: '686',
      sequence_number: '32',
      city_part: 'Nové Sady',
      city: 'Olomouc',
      post_code: 77_900
    },
      email: 'foton@github.com',
      mobile_phone: '+420777888999' }
  end
end

TryApiCalls.new.run
# TryApiCalls.new.download_xsds
