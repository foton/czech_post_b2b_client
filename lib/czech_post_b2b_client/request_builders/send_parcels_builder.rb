# frozen_string_literal: true

module CzechPostB2bClient
  module RequestBuilders
    class SendParcelsBuilder < BaseBuilder
      attr_reader :common_data, :parcels

      def initialize(common_data:, parcels:, request_id: 1)
        @common_data = common_data
        @parcels = parcels
        @request_id = request_id
      end

      private

      def validate_data
        if parcels.empty?
          errors.add(:parcels, 'Minimum of 1 parcel is required!')
          fail!
        end

        if parcels.size > 1000
          errors.add(:parcels, 'Maximum of 1000 parcels are allowed!')
          fail!
        end
      end

      def service_data_struct
        ox_element('serviceData') do |srv_data|
          srv_data << ox_element('ns2:sendParcels') do |send_parcels|
            send_parcels << do_parcel_header
            send_parcels << do_parcel_data
          end
        end
      end

      def do_parcel_header
        ox_element('ns2:doParcelHeader') do |parcel_header|
          parcel_header << ox_element('ns2:transmissionDate', value: common_data[:parcels_sending_date]) # Predpokladane datum podani
          parcel_header << ox_element('ns2:customerID', value: common_data[:customer_id]) # Technologicke cislo podavatele
          parcel_header << ox_element('ns2:postCode', value: common_data[:sending_post_office_code]) # PSC podaci posty
          parcel_header << ox_element('ns2:contractNumber', value: common_data[:contract_number]) # Nepovinne: Cislo zakazky
          parcel_header << ox_element('ns2:frankingNumber', value: common_data[:franking_machine_number]) # Nepovinne: Cislo vyplatniho stroje
          parcel_header << ox_element('ns2:transmissionEnd', value: common_data[:close_requests_batch]) # Nepovinna, default true: Indikace zda uzavritpodani, nebo budou jeste nasledovat dalsi requesty pro stejne podani
          parcel_header << sender_address
          parcel_header << cache_on_delivery_address
          parcel_header << cache_on_delivery_bank
          parcel_header << sender_contacts
          parcel_header << ox_element('ns2:senderCustCardNum', value: sender_data[:custom_card_number]) # Nepovinne: cislo zakaznicke karty odesilatele
          parcel_header << ox_element('ns2:locationNumber', value: common_data[:sending_post_office_location_number]) # Nepovinne: cislo podaciho mista
        end
      end

      def do_parcel_data
        ox_element('ns2:doParcelData') do |do_parcel_data|
          parcels.each do |parcel| # 1-1000x
            do_parcel_data << do_parcel_params(parcel)
            add_parcel_services(do_parcel_data, parcel)
            do_parcel_data << do_parcel_address(parcel)
            do_parcel_data << do_parcel_address_document(parcel)
            do_parcel_data << do_parcel_customs_declaration(parcel)
          end
        end
      end

      def sender_address
        ox_element('ns2:senderAddress') do |s_address|
          add_address_elements(s_address, sender_data[:address])
        end
      end

      def cache_on_delivery_address
        ox_element('ns2:codAddress') do |cod_address|
          add_address_elements(cod_address, common_data[:cash_on_delivery][:address])
        end
      end

      def cache_on_delivery_bank
        ox_element('ns2:codBank') do |cod_bank|
          add_bank_elements(cod_bank, common_data[:cash_on_delivery][:bank_account])
        end
      end

      def sender_contacts
        ox_element('ns2:senderContacts') do |element|
          add_contact_elements(element, sender_data) # Nepovinne. Telefon, Mobil a Email
        end
      end

      def do_parcel_params(parcel_data)
        params = parcel_data[:params]
        cod = parcel_data[:cash_on_delivery]
        ox_element('ns2:doParcelParams') do |parcel_params|
          parcel_params << ox_element('ns2:recordID', value: params[:record_id]) # Unikatni ID zaznamu
          parcel_params << ox_element('ns2:parcelCode', value: params[:parcel_code]) # Nepovinne: ID zasilky
          parcel_params << ox_element('ns2:prefixParcelCode', value: params[:parcel_code_prefix]) # Typ zasilky (prefix)
          parcel_params << ox_element('ns2:weight', value: params[:weight_in_kg]) # Nepovinne: Hmotnost
          parcel_params << ox_element('ns2:insuredValue', value: params[:insured_value]) # Nepovinne: Udana cena
          parcel_params << ox_element('ns2:amount', value: cod[:amount]) # Nepovinne: Dobirka
          parcel_params << ox_element('ns2:currency', value: cod[:currency_iso_code]) # Nepovinne, default CZK: ISO kod meny dobirky
          parcel_params << ox_element('ns2:vsVoucher', value: params[:voucher_variable_symbol]) # Nepovinne: Variabilni symbol - poukazka
          parcel_params << ox_element('ns2:vsParcel', value: params[:parcel_variable_symbol]) # Nepovinne: Variabilni symbol - zasilka
          parcel_params << ox_element('ns2:sequenceParcel', value: params[:parcel_order]) # Nepovinne: Poradi v ramci vicekusove zasilky
          parcel_params << ox_element('ns2:quantityParcel', value: params[:parcels_count]) # Nepovinne: Celkovy pocet zasilek vicekusove zasilky
          parcel_params << ox_element('ns2:note', value: params[:note]) # Nepovinne: Poznamka
          parcel_params << ox_element('ns2:notePrint', value: params[:note_for_print]) # Nepovinne: Poznamka pro tisk
          parcel_params << ox_element('ns2:lenght', value: params[:lenght]) # Nepovinne: Delka
          parcel_params << ox_element('ns2:width', value: params[:width]) # Nepovinne: Sirka
          parcel_params << ox_element('ns2:height', value: params[:height]) # Nepovinne: Vyska
          parcel_params << ox_element('ns2:mrn', value: params[:mrn_code]) # Nepovinne: Kod MRN
          parcel_params << ox_element('ns2:referenceNumber', value: params[:reference_number]) # Nepovinne: Cislo jednaci
          parcel_params << ox_element('ns2:pallets', value: params[:pallets_count]) # Nepovinne: Pocet palet
          parcel_params << ox_element('ns2:specSym', value: params[:specific_symbol]) # Nepovinne: Specificky symbol
          parcel_params << ox_element('ns2:note2', value: params[:note2]) # Nepovinne: Poznamka 2
          parcel_params << ox_element('ns2:numSign', value: params[:documents_to_sign_count]) # Nepovinne: Počet dokumentů
          parcel_params << ox_element('ns2:score', value: params[:score]) # Nepovinne: Napocet ceny sluzby
          parcel_params << ox_element('ns2:orderNumberZPRO', value: params[:zpro_order_number]) # Nepovinne: Cislo objednavky ZPRO
          parcel_params << ox_element('ns2:returnNumDays', value: params[:days_to_deposit]) # Nepovinne: Pocet dni pro vraceni zasilky
        end
      end

      def add_parcel_services(parent_struct, parcel_data)
        parcel_data[:services].each do |p_service|
          parent_struct << ox_element('ns2:doParcelService') do |dps|
            dps << ox_element('ns2:service', value: p_service)
          end
        end
      end

      def do_parcel_address(parcel_data)
        addressee_data = parcel_data[:addressee]
        address_data = addressee_data[:address]
        ox_element('ns2:doParcelAddress') do |element|
          element << ox_element('ns2:recordID', value: addressee_data[:addressee_id]) # Nepovinne: Interni oznaceni adresata

          add_address_elements(element, address_data) # Nepovinne: Adresa

          element << ox_element('ns2:subject', value: addressee_data[:addressee_type]) # Nepovinne: Typ adresata
          element << ox_element('ns2:ic', value: addressee_data[:ic]) # Nepovinne: ICO
          element << ox_element('ns2:dic', value: addressee_data[:dic]) # Nepovinne: DIC
          element << ox_element('ns2:specification', value: addressee_data[:addressee_specification]) # Nepovinne: Specifikace napr. datum narozeni

          add_bank_elements(element, addressee_data[:bank_account]) # Nepovinne. Kod banky, cislo a predcisli uctu
          add_contact_elements(element, addressee_data) # Nepovinne. Telefon, Mobil a Email

          element << ox_element('ns2:custCardNum', value: addressee_data[:custom_card_number]) # Nepovinne: cislo zakaznicke karty

          addressee_data[:advice_informations].each_with_index do |adv_info, index|
            element << ox_element('ns2:adviceInformation' + index.to_s, value: adv_info) # Nepovinne: Informace 1- 6 k dodejce
          end

          element << ox_element('ns2:adviceNote', value: addressee_data[:advice_note]) # Nepovinne: Poznamka k dodejce
        end
      end

      def do_parcel_address_document(parcel_data)
        addressee_data = parcel_data[:document_addressee]
        address_data = addressee_data[:address]
        ox_element('ns2:doParcelAddress') do |element|
          element << ox_element('ns2:recordID', value: addressee_data[:addressee_id]) # Nepovinne: Interni oznaceni adresata

          add_address_elements(element, address_data) # Nepovinne: Adresa

          element << ox_element('ns2:subject', value: addressee_data[:addressee_type]) # Nepovinne: Typ adresata
          element << ox_element('ns2:ic', value: addressee_data[:ic]) # Nepovinne: ICO
          element << ox_element('ns2:dic', value: addressee_data[:dic]) # Nepovinne: DIC
          element << ox_element('ns2:specification', value: addressee_data[:addressee_specification]) # Nepovinne: Specifikace napr. datum narozeni

          add_bank_elements(element, addressee_data[:bank_account]) # Nepovinne. Kod banky, cislo a predcisli uctu
          add_contact_elements(element, addressee_data) # Nepovinne. Telefon, Mobil a Email

          element << ox_element('ns2:custCardNum', value: addressee_data[:custom_card_number]) # Nepovinne: cislo zakaznicke karty

          addressee_data[:advice_informations].each_with_index do |adv_info, index|
            element << ox_element('ns2:adviceInformation' + index.to_s, value: adv_info) # Nepovinne: Informace 1- 6 k dodejce
          end

          element << ox_element('ns2:adviceNote', value: addressee_data[:advice_note]) # Nepovinne: Poznamka k dodejce
        end
      end

      def do_parcel_customs_declaration(parcel_data)
        declaration_data = parcel_data[:custom_declaration]
        descriptions = declaration_data[:content_descriptions]

        ox_element('ns2:doParcelCustomsDeclaration') do |element|
          element << ox_element('ns2:category', value: declaration_data[:category]) # Kategorie zasilky
          element << ox_element('ns2:note', value: declaration_data[:note]) # Nepovinne: Poznamka
          element << ox_element('ns2:customValCur', value: declaration_data[:value_currency_iso_code]) # ISO kod meny celni hodnoty

          descriptions.each do |dsc|
            element << custom_goods_for(dsc)
          end
        end
      end

      def custom_goods_for(description_data)
        ox_element('ns2:doParcelCustomsGoods') do |element|
          element << ox_element('ns2:sequence', value: description_data[:order]) # Nepovinne: Poradi
          element << ox_element('ns2:customCont', value: description_data[:description]) # Nepovinne: Popis zbozi
          element << ox_element('ns2:quantity', value: description_data[:quantity]) # Nepovinne: Mnozstvi
          element << ox_element('ns2:weight', value: description_data[:weight_in_kg]) # Nepovinne: Hmotnost
          element << ox_element('ns2:customVal', value: description_data[:value]) # Nepovinne: Celni hodnota
          element << ox_element('ns2:hsCode', value: description_data[:hs_code]) # Nepovinne: HS kod
          element << ox_element('ns2:iso', value: description_data[:origin_country_iso_code]) # Nepovinne: Zeme puvodu zbozi
        end
      end

      def add_address_elements(parent_element, address_data) # Nepovinne. Adresa
        parent_element << ox_element('ns2:firstName', value: address_data[:first_name]) unless address_data[:first_name].nil? # Nepovinne: Jmeno
        parent_element << ox_element('ns2:surname', value: address_data[:last_name]) unless address_data[:last_name].nil? # Nepovinne: Prijmeni
        parent_element << ox_element('ns2:companyName', value: address_data[:company_name]) # Nepovinne: Nazev spolecnosti
        parent_element << ox_element('ns2:aditionAddress', value: address_data[:addition_to_name]) # Nepovinne: Doplnujici iformace k nazvu podavatele
        parent_element << ox_element('ns2:street', value: address_data[:street]) # Nepovinne: Ulice
        parent_element << ox_element('ns2:houseNumber', value: address_data[:house_number]) # Nepovinne: Cislo popisne
        parent_element << ox_element('ns2:sequenceNumber', value: address_data[:sequence_number]) # Nepovinne: Cislo orientacni
        parent_element << ox_element('ns2:partCity', value: address_data[:city_part]) # Nepovinne: Cast obce
        parent_element << ox_element('ns2:city', value: address_data[:city]) # Nepovinne: Obec
        parent_element << ox_element('ns2:zipCode', value: address_data[:post_code]) # Nepovinne: PSC
        parent_element << ox_element('ns2:isoCountry', value: address_data[:country_iso_code]) # Nepovinne, default 'CZ': ISO kod zeme
        parent_element << ox_element('ns2:subIsoCountry', value: address_data[:subcountry_iso_code]) # Nepovinne: ISO kod uzemi
      end

      def add_bank_elements(parent_element, bank_account)
        if (m = bank_account.match(%r{((\d+)-)?(\d+)\/(\d+)}))
          prefix = m[1]
          account = m[3]
          bank = m[4]
        else
          prefix, account, bank = nil
        end

        parent_element << ox_element('ns2:prefixAccount', value: prefix) # Nepovinne: Predcisli k uctu
        parent_element << ox_element('ns2:account', value: account) # Nepovinne: cislo uctu
        parent_element << ox_element('ns2:bank', value: bank) # Nepovinne: kod banky
      end

      def add_contact_elements(parent_element, data_hash)
        parent_element << ox_element('ns2:mobileNumber', value: data_hash[:mobile_phone]) # Nepovinne: Mobil
        parent_element << ox_element('ns2:phoneNumber', value: data_hash[:phone]) # Nepovinne: Telefon
        parent_element << ox_element('ns2:emailAddress', value: data_hash[:email]) # Nepovinne: Email
      end



      def sender_data
        common_data[:sender]
      end

    end
  end
end
