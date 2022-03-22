# frozen_string_literal: true

# rubocop:disable Layout/LineLength

module CzechPostB2bClient
  module RequestBuilders
    class SendParcelsBuilder < BaseBuilder # rubocop:disable Metrics/ClassLength
      attr_reader :common_data, :parcels

      def initialize(common_data:, parcels:, request_id: 1)
        super()
        @common_data = common_data
        @parcels = parcels
        @request_id = request_id
      end

      private

      def validate_data
        errors.add(:parcels, 'Maximum of 1000 parcels are allowed!') if parcels.size > 1000

        validate_common_data_required_fields
        validate_parcels_required_fields

        fail! unless errors.empty?
      end

      def service_data_struct
        new_element('serviceData').tap do |srv_data|
          add_element_to(srv_data, send_parcels)
        end
      end

      def validate_common_data_required_fields
        [[:parcels_sending_date],
         [:customer_id],
         [:sending_post_office_code]].each do |key_chain|
           value = common_data.dig(*key_chain)
           errors.add(:common_data, "Missing value for key { :#{key_chain.join(' => :')} }!") if value.nil? || value == ''
         end
      end

      def validate_parcels_required_fields
        return if parcels.empty?

        rq_fields = [
          %i[params parcel_id],
          %i[params parcel_code_prefix],
          %i[addressee address last_name],
          %i[addressee address street],
          %i[addressee address house_number],
          %i[addressee address city],
          %i[addressee address post_code]
        ]
        parcels.each_with_index do |parcel_data, index|
          parcel_id = parcel_data.dig(:params, :parcel_id)
          rq_fields.each do |key_chain|
            value = parcel_data.dig(*key_chain)

            if value.nil? || value == ''
              errors.add(:parcels, "Missing value for key { :#{key_chain.join(' => :')} } for #{index + 1}. parcel (parcel_id: '#{parcel_id}')!")
            end
          end
        end
      end

      def send_parcels
        new_element('ns2:sendParcels').tap do |send_parcels|
          add_element_to(send_parcels, do_parcel_header) # REQUIRED
          parcels.each do |parcel|
            add_element_to(send_parcels, do_parcel_data(parcel)) # optional
          end
        end
      end

      def do_parcel_header # rubocop:disable Metrics/AbcSize
        new_element('ns2:doParcelHeader').tap do |parcel_header|
          add_element_to(parcel_header, 'ns2:transmissionDate', value: common_data[:parcels_sending_date].strftime('%d.%m.%Y')) # Predpokladane datum podani (format DD.MM.YYYY !)
          add_element_to(parcel_header, 'ns2:customerID', value: common_data[:customer_id]) # Technologicke cislo podavatele
          add_element_to(parcel_header, 'ns2:postCode', value: common_data[:sending_post_office_code]) # PSC podaci posty
          add_element_to(parcel_header, 'ns2:contractNumber', value: common_data[:contract_number]) # Nepovinne: Cislo zakazky
          add_element_to(parcel_header, 'ns2:frankingNumber', value: common_data[:franking_machine_number]) # Nepovinne: Cislo vyplatniho stroje
          add_element_to(parcel_header, 'ns2:transmissionEnd', value: common_data[:close_requests_batch]) # Nepovinna, default true: Indikace zda uzavrit podani, nebo budou jeste nasledovat dalsi requesty pro stejne podani
          add_element_to(parcel_header, sender_address)
          add_element_to(parcel_header, cache_on_delivery_address)
          add_element_to(parcel_header, cache_on_delivery_bank)
          add_element_to(parcel_header, sender_contacts)
          add_element_to(parcel_header, 'ns2:senderCustCardNum', value: sender_data[:custom_card_number]) # Nepovinne: cislo zakaznicke karty odesilatele
          add_element_to(parcel_header, 'ns2:locationNumber', value: common_data[:sending_post_office_location_number]) # Nepovinne: cislo podaciho mista (z nastaveni v Podani Online)
        end
      end

      def do_parcel_data(parcel)
        new_element('ns2:doParcelData').tap do |do_parcel_data|
          add_element_to(do_parcel_data, do_parcel_params(parcel))
          add_parcel_services(do_parcel_data, parcel)
          add_element_to(do_parcel_data, do_parcel_address(parcel))
          add_element_to(do_parcel_data, do_parcel_address_document(parcel))
          add_element_to(do_parcel_data, do_parcel_customs_declaration(parcel))
        end
      end

      def sender_address
        add_header_address_element('ns2:senderAddress', sender_data)
      end

      def cache_on_delivery_address
        add_header_address_element('ns2:codAddress', common_data[:cash_on_delivery])
      end

      def cache_on_delivery_bank
        data = common_data.dig(:cash_on_delivery, :bank_account)
        return nil unless data

        new_element('ns2:codBank').tap do |cod_bank|
          add_bank_elements(cod_bank, data)
        end
      end

      def sender_contacts
        return nil unless sender_data

        new_element('ns2:senderContacts').tap do |element|
          add_contact_elements(element, sender_data) # Nepovinne. Telefon, Mobil a Email
        end
      end

      def do_parcel_params(parcel_data) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        params = parcel_data[:params]
        cod = parcel_data[:cash_on_delivery] || {}
        new_element('ns2:doParcelParams').tap do |parcel_params|
          add_element_to(parcel_params, 'ns2:recordID', value: params[:parcel_id]) # Unikatni ID zaznamu
          add_element_to(parcel_params, 'ns2:parcelCode', value: params[:parcel_code]) # Nepovinne: ID zasilky
          add_element_to(parcel_params, 'ns2:prefixParcelCode', value: params[:parcel_code_prefix]) # Typ zasilky (prefix)
          add_element_to(parcel_params, 'ns2:weight', value: params[:weight_in_kg]) # Nepovinne: Hmotnost
          add_element_to(parcel_params, 'ns2:insuredValue', value: params[:insured_value]) # Nepovinne: Udana cena
          add_element_to(parcel_params, 'ns2:amount', value: cod[:amount]) # Nepovinne: Dobirka
          add_element_to(parcel_params, 'ns2:currency', value: cod[:currency_iso_code]) # Nepovinne, default CZK: ISO kod meny dobirky
          add_element_to(parcel_params, 'ns2:vsVoucher', value: params[:voucher_variable_symbol]) # Nepovinne: Variabilni symbol - poukazka
          add_element_to(parcel_params, 'ns2:vsParcel', value: params[:parcel_variable_symbol]) # Nepovinne: Variabilni symbol - zasilka
          add_element_to(parcel_params, 'ns2:sequenceParcel', value: params[:parcel_order]) # Nepovinne: Poradi v ramci vicekusove zasilky
          add_element_to(parcel_params, 'ns2:quantityParcel', value: params[:parcels_count]) # Nepovinne: Celkovy pocet zasilek vicekusove zasilky
          add_element_to(parcel_params, 'ns2:note', value: params[:note]) # Nepovinne: Poznamka
          add_element_to(parcel_params, 'ns2:notePrint', value: params[:note_for_print]) # Nepovinne: Poznamka pro tisk
          add_element_to(parcel_params, 'ns2:length', value: params[:length]) # Nepovinne: Delka
          add_element_to(parcel_params, 'ns2:width', value: params[:width]) # Nepovinne: Sirka
          add_element_to(parcel_params, 'ns2:height', value: params[:height]) # Nepovinne: Vyska
          add_element_to(parcel_params, 'ns2:mrn', value: params[:mrn_code]) # Nepovinne: Kod MRN
          add_element_to(parcel_params, 'ns2:referenceNumber', value: params[:reference_number]) # Nepovinne: Cislo jednaci
          add_element_to(parcel_params, 'ns2:pallets', value: params[:pallets_count]) # Nepovinne: Pocet palet
          add_element_to(parcel_params, 'ns2:specSym', value: params[:specific_symbol]) # Nepovinne: Specificky symbol
          add_element_to(parcel_params, 'ns2:note2', value: params[:note2]) # Nepovinne: Poznamka 2
          add_element_to(parcel_params, 'ns2:numSign', value: params[:documents_to_sign_count]) # Nepovinne: Počet dokumentů
          add_element_to(parcel_params, 'ns2:score', value: params[:score]) # Nepovinne: Napocet ceny sluzby
          add_element_to(parcel_params, 'ns2:orderNumberZPRO', value: params[:zpro_order_number]) # Nepovinne: Cislo objednavky ZPRO
          add_element_to(parcel_params, 'ns2:returnNumDays', value: params[:days_to_deposit]) # Nepovinne: Pocet dni pro vraceni zasilky
        end
      end

      def add_parcel_services(parent_element, parcel_data)
        (parcel_data[:services] || []).each do |p_service|
          srv_element = new_element('ns2:doParcelServices').tap do |dps|
            add_element_to(dps, 'ns2:service', value: p_service)
          end

          add_element_to(parent_element, srv_element)
        end
      end

      def do_parcel_address(parcel_data)
        add_parcel_adress_element('ns2:doParcelAddress', parcel_data[:addressee])
      end

      def do_parcel_address_document(parcel_data)
        add_parcel_adress_element('ns2:doParcelAddressDocument', parcel_data[:document_addressee])
      end

      def add_header_address_element(element_name, addressee_data) # rubocop:disable Metrics/AbcSize
        return nil if addressee_data.nil?

        address_data = addressee_data[:address]

        new_element(element_name).tap do |do_parcel_address|
          add_element_to(do_parcel_address, 'ns2:companyName', value: address_data[:company_name]) # Nepovinne: Nazev spolecnosti
          add_element_to(do_parcel_address, 'ns2:aditionAddress', value: address_data[:addition_to_name]) # Nepovinne: Doplnujici iformace k nazvu podavatele
          add_element_to(do_parcel_address, 'ns2:street', value: address_data[:street]) # Nepovinne: Ulice
          add_element_to(do_parcel_address, 'ns2:houseNumber', value: address_data[:house_number]) # Nepovinne: Cislo popisne
          add_element_to(do_parcel_address, 'ns2:sequenceNumber', value: address_data[:sequence_number]) # Nepovinne: Cislo orientacni
          add_element_to(do_parcel_address, 'ns2:partCity', value: address_data[:city_part]) # Nepovinne: Cast obce
          add_element_to(do_parcel_address, 'ns2:city', value: address_data[:city]) # Nepovinne: Obec
          add_element_to(do_parcel_address, 'ns2:zipCode', value: address_data[:post_code]) # Nepovinne: PSC
          add_element_to(do_parcel_address, 'ns2:isoCountry', value: address_data[:country_iso_code]) # Nepovinne, default 'CZ': ISO kod zeme
          add_element_to(do_parcel_address, 'ns2:subIsoCountry', value: address_data[:subcountry_iso_code]) # Nepovinne: ISO kod uzemi
        end
      end

      def add_parcel_adress_element(element_name, addressee_data) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        return nil if addressee_data.nil?

        address_data = addressee_data[:address]

        new_element(element_name).tap do |do_parcel_address|
          add_element_to(do_parcel_address, 'ns2:recordID', value: addressee_data[:addressee_id]) # Nepovinne: Interni oznaceni adresata
          add_element_to(do_parcel_address, 'ns2:firstName', value: address_data[:first_name]) # Nepovinne: Jmeno
          add_element_to(do_parcel_address, 'ns2:surname', value: address_data[:last_name]) # Nepovinne: Prijmeni
          add_element_to(do_parcel_address, 'ns2:companyName', value: address_data[:company_name]) # Nepovinne: Nazev spolecnosti
          add_element_to(do_parcel_address, 'ns2:aditionAddress', value: address_data[:addition_to_name]) # Nepovinne: Doplnujici iformace k nazvu podavatele

          add_element_to(do_parcel_address, 'ns2:subject', value: addressee_data[:addressee_type]) # Nepovinne: Typ adresata
          add_element_to(do_parcel_address, 'ns2:ic', value: addressee_data[:ic]) # Nepovinne: ICO
          add_element_to(do_parcel_address, 'ns2:dic', value: addressee_data[:dic]) # Nepovinne: DIC
          add_element_to(do_parcel_address, 'ns2:specification', value: addressee_data[:addressee_specification]) # Nepovinne: Specifikace napr. datum narozeni

          add_element_to(do_parcel_address, 'ns2:street', value: address_data[:street]) # Nepovinne: Ulice
          add_element_to(do_parcel_address, 'ns2:houseNumber', value: address_data[:house_number]) # Nepovinne: Cislo popisne
          add_element_to(do_parcel_address, 'ns2:sequenceNumber', value: address_data[:sequence_number]) # Nepovinne: Cislo orientacni
          add_element_to(do_parcel_address, 'ns2:partCity', value: address_data[:city_part]) # Nepovinne: Cast obce
          add_element_to(do_parcel_address, 'ns2:city', value: address_data[:city]) # Nepovinne: Obec
          add_element_to(do_parcel_address, 'ns2:zipCode', value: address_data[:post_code]) # Nepovinne: PSC
          add_element_to(do_parcel_address, 'ns2:isoCountry', value: address_data[:country_iso_code]) # Nepovinne, default 'CZ': ISO kod zeme
          add_element_to(do_parcel_address, 'ns2:subIsoCountry', value: address_data[:subcountry_iso_code]) # Nepovinne: ISO kod uzemi

          add_bank_elements(do_parcel_address, addressee_data[:bank_account]) # Nepovinne. Kod banky, cislo a predcisli uctu
          add_contact_elements(do_parcel_address, addressee_data) # Nepovinne. Telefon, Mobil a Email

          add_element_to(do_parcel_address, 'ns2:custCardNum', value: addressee_data[:custom_card_number]) # Nepovinne: cislo zakaznicke karty

          (addressee_data[:advice_informations] || []).each_with_index do |adv_info, index|
            add_element_to(do_parcel_address, "ns2:adviceInformation#{index + 1}", value: adv_info) # Nepovinne: Informace 1- 6 k dodejce
          end
          add_element_to(do_parcel_address, 'ns2:adviceNote', value: addressee_data[:advice_note]) # Nepovinne: Poznamka k dodejce
        end
      end

      def do_parcel_customs_declaration(parcel_data)
        declaration_data = parcel_data[:custom_declaration]
        return nil if declaration_data.nil?

        new_element('ns2:doParcelCustomsDeclaration').tap do |do_p_customs_declaration|
          add_element_to(do_p_customs_declaration, 'ns2:category', value: declaration_data[:category]) # Kategorie zasilky
          add_element_to(do_p_customs_declaration, 'ns2:note', value: declaration_data[:note]) # Nepovinne: Poznamka
          add_element_to(do_p_customs_declaration, 'ns2:customValCur', value: declaration_data[:value_currency_iso_code]) # ISO kod meny celni hodnoty

          (declaration_data[:content_descriptions] || []).each do |dsc|
            do_p_customs_declaration << custom_goods_for(dsc)
          end
        end
      end

      def custom_goods_for(description_data)
        new_element('ns2:doParcelCustomsGoods').tap do |do_p_customs_goods|
          add_element_to(do_p_customs_goods, 'ns2:sequence', value: description_data[:order]) # Nepovinne: Poradi
          add_element_to(do_p_customs_goods, 'ns2:customCont', value: description_data[:description]) # Nepovinne: Popis zbozi
          add_element_to(do_p_customs_goods, 'ns2:quantity', value: description_data[:quantity]) # Nepovinne: Mnozstvi
          add_element_to(do_p_customs_goods, 'ns2:weight', value: description_data[:weight_in_kg]) # Nepovinne: Hmotnost
          add_element_to(do_p_customs_goods, 'ns2:customVal', value: description_data[:value]) # Nepovinne: Celni hodnota
          add_element_to(do_p_customs_goods, 'ns2:hsCode', value: description_data[:hs_code]) # Nepovinne: HS kod
          add_element_to(do_p_customs_goods, 'ns2:iso', value: description_data[:origin_country_iso_code]) # Nepovinne: Zeme puvodu zbozi
        end
      end

      # Nepovinne. Adresa
      def add_address_elements(parent_element, address_data, without: [])
        return if address_data.nil?

        address_tags_and_values(address_data).each_pair do |xml_tag, value|
          add_element_to(parent_element, xml_tag, value: value) if !without.include?(xml_tag) && !value.nil?
        end
      end

      def address_tags_and_values(address_data)
        {
          'ns2:firstName' => address_data[:first_name], # Nepovinne: Jmeno
          'ns2:surname' => address_data[:last_name], # Nepovinne: Prijmeni
          'ns2:companyName' => address_data[:company_name], # Nepovinne: Nazev spolecnosti
          'ns2:aditionAddress' => address_data[:addition_to_name], # Nepovinne: Doplnujici iformace k nazvu podavatele
          'ns2:street' => address_data[:street], # Nepovinne: Ulice
          'ns2:houseNumber' => address_data[:house_number], # Nepovinne: Cislo popisne
          'ns2:sequenceNumber' => address_data[:sequence_number], # Nepovinne: Cislo orientacni
          'ns2:partCity' => address_data[:city_part], # Nepovinne: Cast obce
          'ns2:city' => address_data[:city], # Nepovinne: Obec
          'ns2:zipCode' => address_data[:post_code], # Nepovinne: PSC
          'ns2:isoCountry' => address_data[:country_iso_code], # Nepovinne, default 'CZ': ISO kod zeme
          'ns2:subIsoCountry' => address_data[:subcountry_iso_code] # Nepovinne: ISO kod uzemi
        }
      end

      def add_bank_elements(parent_element, bank_account)
        return if bank_account.to_s == ''

        if (m = bank_account.match(%r{(?:(\d+)-)?(\d+)/(\d+)}))
          prefix = m[1]
          account = m[2]
          bank = m[3]
        else
          prefix, account, bank = nil
        end

        add_element_to(parent_element, 'ns2:bank', value: bank) # Nepovinne: kod banky
        add_element_to(parent_element, 'ns2:prefixAccount', value: prefix) # Nepovinne: Predcisli k uctu
        add_element_to(parent_element, 'ns2:account', value: account) # Nepovinne: cislo uctu
      end

      def add_contact_elements(parent_element, data_hash)
        add_element_to(parent_element, 'ns2:mobileNumber', value: data_hash[:mobile_phone]) # Nepovinne: Mobil
        add_element_to(parent_element, 'ns2:phoneNumber', value: data_hash[:phone]) # Nepovinne: Telefon
        add_element_to(parent_element, 'ns2:emailAddress', value: data_hash[:email]) # Nepovinne: Email
      end

      def sender_data
        common_data[:sender]
      end
    end
  end
end

# rubocop:enable Layout/LineLength
