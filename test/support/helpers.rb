# frozen_string_literal: true

def setup_configuration(config_hash = {})
  CzechPostB2bClient.configure do |config|
    config.contract_id = 'contract_id' # from CP signed contract
    config.customer_id = 'customer_id' # from CP signed contract
    config.certificate_path = 'full_path/to/your/postsignum_certificate'
    config.certificate_password = 'certificate_password'
    config.sending_post_office_code = 12_345 # PSC of post office where parcels will be physically delivered and submitted
    #config.logger = Logger.new(STDOUT)

    config_hash.each_pair do |k, v|
      config.send("#{k}=",v)
    end
  end
end

def configuration
  CzechPostB2bClient.configuration
end

def full_common_data
  {
    contract_id: configuration.contract_id,
    customer_id: 'U219',
    parcels_sending_date: Date.new(2016, 02, 12),
    sending_post_office_code: 28_002,
    sending_post_office_location_number: 98_765, # optional
    close_requests_batch: false, # optional; we want to use more requests for one bulk delivery  (default is true, one request = one delivery)
    sender: full_sender_data, # optional?, from config?
    cash_on_delivery: full_cash_on_delivery_data, # optional?, from config?
    contract_number: 'string10', # optional
    franking_machine_number: 'string10f' , # optional
  }
end

def short_common_data
  shortie = full_common_data.select { |k, _v| %i[customer_id parcels_sending_date sending_post_office_code].include?(k) }
  shortie.merge(sender: short_sender_data)
end

def full_sender_data
  {
    address: {
      first_name: 'Should not appear',
      last_name: 'Should not appear',
      company_name: 'Oriflame',
      addition_to_name: 'perfume', # optional
      street: 'V olšinách',
      house_number: '16',
      sequence_number: '82',
      city_part: 'Strašnice',
      city: 'Praha',
      post_code: 10_000,
      country_iso_code: 'CZ'
    },
    mobile_phone: '+420777888999', # optional
    phone: '+420027912191', # optional
    email: 'rehor.jan@cpost.cz', # optional
    custom_card_number: 'string_20' # optional
  }
end

def short_sender_data
  shortie = full_sender_data.select { |k, _v| %i[mobile_phone email].include?(k) }
  shortie[:address] = full_sender_data[:address].reject do |k, _v|
    %i[first_name last_name addition_to_name sequence_number country_iso_code].include?(k)
  end
  shortie
end

def full_cash_on_delivery_data
  {
    address: {
      first_name: 'Should not appear',
      last_name: 'Should not appear',
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

def full_parcel_data
  {
    params: full_parcel_data_params, # required
    cash_on_delivery: { amount: 12_345.678, currency_iso_code: 'CZK' },
    services: %w[43 44 s3],
    addressee: full_addressee_data,
    document_addressee: full_addressee_data, # 0-X
    custom_declaration: full_parcel_data_custom_delaration # 0-1
  }
end


def full_parcel_data_params
  {
    record_id: 'my_id', # REQUIRED; purpose? something like custom_id ?
    parcel_code: '123456789W', # (will be assigned by CzechPost if not presnt?), string13
    parcel_code_prefix: 'RR', # # REQUIRED; string 2; something like `parcel_type`?
    weight_in_kg: 12_345.678, # hopefuly in KG
    insured_value: 123_456_789.01,
    voucher_variable_symbol: 1_234_567_890,
    parcel_variable_symbol: 2_345_678_910,
    specific_symbol: '1234567890',
    parcel_order: 2,
    parcels_count: 3,
    note: 'string_50',
    note2: 'string_50_2',
    note_for_print: 'string_50_print',
    length: 123,
    width: 231,
    height: 312,
    mrn_code: '15CZ65000021QMDZN0', # string18, what it is MRN code?
    reference_number: 'string30', # cislo jednaci
    pallets_count: 1, # 1-99
    documents_to_sign_count: 'string30', # he?
    score: 'string30', # napocet ceny sluzby
    zpro_order_number: 'string11', # cislo objednavky ZPRO
    days_to_deposit: 's2', # pocet dni pro vraceni zasilky
  }
end

def short_parcel_data
  {
    params: full_parcel_data_params.select { |k, _v| %i[record_id parcel_code_prefix].include?(k) },
    addressee: short_addressee_data
  }
end

def full_addressee_data
  # all items optional?!
  {
    address: {
      first_name: 'Ján',
      last_name: 'Nový',
      company_name: 'Empire observatory',
      addition_to_name: 'state building',
      street: 'West 34th Street',
      house_number: '20',
      sequence_number: '3',
      city_part: 'Manhattan',
      city: 'New York',
      post_code: 10_118,
      country_iso_code: 'US',
      subcountry_iso_code: 'US-NY'
    },
    addressee_id: 'string20',
    addressee_type: 'F',  # string2; => <subject>
    ic: 1_234_567_890,
    dic: 'AB1234567890',
    addressee_specification: 'date_of_birth', # string15, specifikace adresata, napr. datum narozeni
    bank_account: '234561-2345678901/2341',
    mobile_phone: 'do not have, kidding',
    phone: '+1(212)710-1364',
    email: 'jan.novy@ny.us',
    custom_card_number: 'string_20',
    advice_informations: Array.new(6) { |i| "string10_#{i + 1}" },
    advice_note: 'string15'
  }
end

def short_addressee_data
  shortie = full_addressee_data.select { |k, _v| %i[email].include?(k) }
  shortie[:address] = full_addressee_data[:address].reject do |k, _v|
    %i[company_name addition_to_name sequence_number country_iso_code subcountry_iso_code].include?(k)
  end
  shortie
end

def full_parcel_data_custom_delaration
  {
    category: 's2', # REQUIRED, kategorie zasilky
    note: 'string30',
    value_currency_iso_code: 'CZK', # REQUIRED, ISO kod meny celni hodnoty
    content_descriptions: [ # 1- 20x; popis obsahu zasilky
      {
        order: 1, # # REQUIRED, 1-20
        description: 'string50: heavy metal', # REQUIRED, popis zbozi
        quantity: 'string50: many', # REQUIRED
        weight_in_kg: 3.777, # REQUIRED
        value: 123_456_789.01, # REQUIRED
        hs_code: 'string6', # REQUIRED
        origin_country_iso_code: 'CS' # REQUIRED, string2
      },
      {
        order: 2, # # REQUIRED, 1-20
        description: 'string50: light metal', # REQUIRED, popis zbozi
        quantity: 'string50: few', # REQUIRED
        weight_in_kg: 0.777, # REQUIRED
        value: 123.01, # REQUIRED
        hs_code: 'string6', # REQUIRED
        origin_country_iso_code: 'CS' # REQUIRED, string2
      }
    ]
  }
end
