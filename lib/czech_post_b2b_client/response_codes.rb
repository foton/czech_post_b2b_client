# frozen_string_literal: true

# Codes, which can be returned in response nodes `doParcelStateResponse`
#
# Do not miss `CzechPostB2bClient::ResponseCodes.all_classes` and `CzechPostB2bClient::ResponseCodes.new_by_code`,
# they have to be at end of module to work properly
module CzechPostB2bClient
  module ResponseCodes # rubocop:disable Metrics/ModuleLength
    class BaseCode
      @code = 'undefined'
      @text = '_NONE_'
      @decription = 'Unspecified B2B response code, is it listed in /doc/.../ResponseCodes.ods'

      class << self
        attr_reader :code
      end

      class << self
        attr_reader :text
      end

      class << self
        attr_reader :description
      end

      attr_reader :details

      def initialize(details = '')
        @details = details
      end

      def self.error?
        @type == :error || @type == :chyba
      end

      def self.info?
        @type == :info
      end

      class << self
        attr_reader :type
      end

      def self.to_s
        "ResponseCode[#{code} #{text}] #{description}"
      end

      def to_s
        "#{self.class} -- #{details}"
      end

      # forwarding instance methods to class
      %i[code text description error? info? type].each do |mth|
        define_method mth do
          self.class.send(mth)
        end
      end
    end

    class Ok < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 1
      @text = 'OK'
      @description = 'Vše v poržadku :-)'
      @type = :info
    end

    class InternalApplicationError < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 2
      @text = 'INTERNAL_APPLICATION_ERROR'
      @description = 'Interní chyba aplikace'
      @type = :error
    end

    class UnauthorizedAccess < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 3
      @text = 'UNAUTHORIZED_ACCESS'
      @description = 'Login není evidován k uvedenému číslu podavatele'
      @type = :error
    end

    class InvalidCustomerId < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 10
      @text = 'INVALID_CUSTOMER_ID'
      @description = 'Neplatne technologické číslo (customer_id)'
      @type = :error
    end

    class InvalidLocation < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 11
      @text = 'INVALID_LOCATION'
      @description = 'Neplatné podací místo, zkuste použít `locationNumber`.'
      @type = :error
    end

    class InvalidPostCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 12
      @text = 'INVALID_POST_CODE'
      @description = 'Neplatné PSČ podací pošty'
      @type = :error
    end

    class InvalidTransmissionDate < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 13
      @text = 'INVALID_TRANSMISSION_DATE'
      @description = 'Chybné datum podání (menší než aktuální datum)'
      @type = :error
    end

    class TransmissionOpened < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 14
      @text = 'TRANSMISSION_OPENED'
      @description = 'Podání otevřeno'
      @type = :error
    end

    class TransmissionAlreadyClosed < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 15
      @text = 'TRANSMISSION_CLOSED'
      @description = 'Podání již bylo uzavřeno'
      @type = :error
    end

    class TransmissionUnfinished < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 16
      @text = 'TRANSMISSION_UNFINISHED'
      @description = 'Zpracování ještě není ukončeno'
      @type = :error
    end

    class BatchClosed < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 17
      @text = 'BATCH_CLOSED'
      @description = 'Dávka uzavřena'
      @type = :error
    end

    class BatchUnfinished < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 18
      @text = 'BATCH_UNFINISHED'
      @description = 'Zpracování ješte není ukončeno'
      @type = :error
    end

    class BatchInvalid < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 19
      @text = 'BATCH_INVALID'
      @description = 'V dávce se vyskytují chybné záznamy'
      @type = :error
    end

    class TransmissionNotExists < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 20
      @text = 'TRANSMISSION_NOT_EXISTS'
      @description = 'Podání neexistuje'
      @type = :error
    end

    class InvalidParcelCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 100
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Neplatné ID zásilky'
      @type = :error
    end

    class DuplicateParcelCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 101
      @text = 'DUPLICATE_PARCEL_CODE'
      @description = 'Duplicitní ID zásilky v rámci 13-ti měsíců'
      @type = :error
    end

    class FullSequence < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 102
      @text = 'FULL_SEQUENCE'
      @description = 'Vyčerpaná řada podacích čísel'
      @type = :error
    end

    class UnknownPrefix < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 103
      @text = 'INVALID_PREFIX'
      @description = 'Neznámý typ zásilky (prefix)'
      @type = :error
    end

    class WeightIsOutOfRangeDuplicate < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 104
      @text = 'INVALID_WEIGHT'
      @description = 'Hmotnost mimo povolený rozsah'
      @type = :error
    end

    class InvalidPrice < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 105
      @text = 'INVALID_PRICE'
      @description = 'Udaná cena mimo povolený rozsah'
      @type = :error
    end

    class InvalidCODAmount < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 106
      @text = 'INVALID_AMOUNT'
      @description = 'Dobírka mimo povolený rozsah'
      @type = :error
    end

    class InvalidCODCurrency < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 107
      @text = 'INVALID_CURRENCY'
      @description = 'Neplatná měna dobírkové částky'
      @type = :error
    end

    class MissingVariableSymbol < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 108
      @text = 'MISSING_VS'
      @description = 'Neuveden variabilní symbol poukázky'
      @type = :error
    end

    class InvalidWidth < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 109
      @text = 'INVALID_WIDTH'
      @description = 'Šířka mimo povolený rozsah'
      @type = :error
    end

    class InvalidHeight < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 110
      @text = 'INVALID_HEIGHT'
      @description = 'Výška mimo povolený rozsah'
      @type = :error
    end

    class InvalidLength < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 111
      @text = 'INVALID_LENGTH'
      @description = 'Délka mimo povolený rozsah'
      @type = :error
    end

    class IllegalCombinationOfServices < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 112
      @text = 'ILLEGAL_COMBINATION_SERVICE'
      @description = 'Nepovolená kombinace doplňkových služeb'
      @type = :error
    end

    class MissingRequiredService < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 113
      @text = 'MISSING_REQUIRED_SERVICE'
      @description = 'Neuvedena alespoň jedna povinná doplňková služba'
      @type = :error
    end

    class MissingSurname < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 114
      @text = 'MISSING_SURNAME'
      @description = 'Neuvedeno příjmení fyzické osoby'
      @type = :error
    end

    class MissingCompanyName < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 115
      @text = 'MISSING_COMPANY_NAME'
      @description = 'Neuveden název právnické osoby'
      @type = :error
    end

    class UnknownAddresseeCity < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 116
      @text = 'UNKNOWN_CITY'
      @description = 'Neznámá obec adresáta'
      @type = :error
    end

    class UnknownAddresseePostCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 117
      @text = 'UNKNOWN_ZIP_CODE'
      @description = 'Neznámé PSC adresáta'
      @type = :error
    end

    class MissingPhoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 118
      @text = 'MISSING_PHONE_NUMBER'
      @description = 'Neuvedeno telefonní číslo'
      @type = :error
    end

    class InvalidAddressForBigPackage < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 119
      @text = 'INVALID_ADRESS'
      @description = 'Adresa odesílatele není vhodná pro produkt Nadrozměrná zásilka' \
                     '(adresa obsahuje údaj P.O.Box nebo Poste restante)!'
      @type = :error
    end

    class DensityOutOfRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 120
      @text = 'INVALID_DENSITY'
      @description = 'Objemová hmotnost mimo povolený rozsah'
      @type = :error
    end

    class BadWeight < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 121
      @text = 'BAD_WEIGHT'
      @description = 'Hmotnost není číslo'
      @type = :error
    end

    class BadPrice < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 122
      @text = 'BAD_PRICE'
      @description = 'Udaná cena není číslo'
      @type = :error
    end

    class BadCODAmount < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 123
      @text = 'BAD_AMOUNT'
      @description = 'Dobírka není číslo'
      @type = :error
    end

    class MissingCODAmount < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 124
      @text = 'MISSING_AMOUNT'
      @description = 'Neuvedena částka dobírky'
      @type = :error
    end

    class MissingRequiredService2X < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 125
      @text = 'MISSING_REQUIRED_SERVICE 20/22/1U'
      @description = 'Neuvedena povinná služba 20 ani 22'
      @type = :error
    end

    class MissingRequiredService3X < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 126
      @text = 'MISSING_REQUIRED_SERVICE 37/38'
      @description = 'Neuvedena povinná služba 37 ani 38'
      @type = :error
    end

    class MissingRequiredService4X < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 127
      @text = 'MISSING_REQUIRED_SERVICE 42/43/44'
      @description = 'Neuvedena povinná služba 42 ani 43 ani 44'
      @type = :error
    end

    class MissingPrefix < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 128
      @text = 'MISSING_PREFIX'
      @description = 'Neuveden typ zásilky'
      @type = :error
    end

    class InvalidWeightForService11 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 129
      @text = 'INVALID_WEIGHT_FOR_SERVICE_11'
      @description = 'Hmotnost mimo povolený rozsah služby 11'
      @type = :error
    end

    class MissingPrice < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 130
      @text = 'MISSING_PRICE'
      @description = 'Neuvedena částka udané ceny'
      @type = :error
    end

    class MissingCODAmountType < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 131
      @text = 'MISSING_AMOUNT_TYPE'
      @description = 'Neuveden typ dobírky'
      @type = :error
    end

    class BadVariableSymbol < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 132
      @text = 'BAD_VS'
      @description = 'Variabilní symbol poukázky není číslo'
      @type = :error
    end

    class BadWidth < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 133
      @text = 'BAD_WIDTH'
      @description = 'Šířka není celé číslo'
      @type = :error
    end

    class BadHeight < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 134
      @text = 'BAD_HEIGHT'
      @description = 'Výška není celé číslo'
      @type = :error
    end

    class BadLength < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 135
      @text = 'BAD_LENGTH'
      @description = 'Délka není celé číslo'
      @type = :error
    end

    class MissingRequiredPhoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 136
      @text = 'MISSING_REQUIRED_PHONE_NUMBER'
      @description = 'Není uveden povinný údaj - telefonní číslo adresáta'
      @type = :error
    end

    class BadPrefixForAddress < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 137
      @text = 'BAD_PREFIX'
      @description = 'Zásilku tohoto typu nelze na uvedenou adresu odeslat'
      @type = :error
    end

    class MissingRequiredPhoneNumberOrEmail < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 138
      @text = 'MISSING_REQUIRED_PHONE_NUMBER_OR_EMAIL'
      @description = 'Není uveden povinný údaj - telefonní číslo nebo email adresáta'
      @type = :error
    end

    class InvalidAddressForCODAmountOver20000 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 139
      @text = 'INVALID_ADRESS_FOR_AMOUNT_OVER_20000'
      @description = 'Zásilku tohoto typu s dobírkou vetší než 20 000 Kč nelze na uvedenou adresu odeslat'
      @type = :error
    end

    class BadPrefix < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 140
      @text = 'BAD_PREFIX'
      @description = 'Zásilku tohoto typu nelze na uvedenou adresu odeslat'
      @type = :error
    end

    class AddressValidOnlyForNaPostu < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 141
      @text = 'INVALID_ADRESS'
      @description = 'Adresa je vhodná pouze pro produkt Na poštu'
      @type = :error
    end

    class InvalidAddressForParcelType < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 142
      @text = 'INVALID_ADRESS'
      @description = 'Adresu nelze zvolit (adresa obsahuje údaj P.O.Box, Poste restante nebo Na poštu)!'
      @type = :error
    end

    class FullSequenceDuplicate < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 143
      @text = 'FULL_SEQUENCE'
      @description = 'Vyčerpaná řada podacích čísel'
      @type = :error
    end

    class DuplicateParcel < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 144
      @text = 'DUPLICATE_PARCEL_CODE'
      @description = 'Duplicitní zásilka'
      @type = :error
    end

    class InvalidParcelCodeControl < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 145
      @text = 'INVALID_PARCEL_CODE_CONTROL'
      @description = 'Nesouhlasí kontrolní číslo v ID zásilky'
      @type = :error
    end

    class MissingRequiredMRNCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 146
      @text = 'MISSING_REQUIRED_MRN_CODE'
      @description = 'Neuveden MRN kód'
      @type = :error
    end

    class InvalidMRNCodeControl < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 147
      @text = 'INVALID_MRN_CODE_CONTROL'
      @description = 'Neplatný kód MRN'
      @type = :error
    end

    class AddressValidOnlyForNaPostuDuplicate < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 150
      @text = 'INVALID_ADRESS'
      @description = 'Adresa je vhodná pouze pro produkt Na poštu'
      @type = :error
    end

    class AddressNeedsPhoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 155
      @text = 'INVALID_ADRESS'
      @description = 'Adresát není vhodný pro produkt Nadrozměrná zásilka (nevyplněn mobil nebo telefon)'
      @type = :error
    end

    class MissingRequiredService1X < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 156
      @text = 'MISSING_REQUIRED_SERVICE 14/19'
      @description = 'Neuvedena povinná služba 14 ani 19'
      @type = :error
    end

    class MissingRequiredPhoneNumberOrWhat < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 159
      @text = 'MISSING_REQUIRED_PHONE_NUMBER'
      @description = 'Nevyplněn variabilní symbol zásilky' # nebo telefonni cislo?!
      @type = :error
    end

    class InvalidParcelResponseCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 160
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Neuvedeno ID odpovědní zásilky'
      @type = :error
    end

    class MIssingParcelCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 161
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Neuvedeno ID zásilky'
      @type = :error
    end

    class CustomerIDNotInAccordanceWithParcelCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 164
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Nesouhlasí technologické číslo s ID zásilky'
      @type = :error
    end

    class BadAddressee < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 165
      @text = 'BAD_ADDRESSEE'
      @description = 'Chybný adresát'
      @type = :error
    end

    class MissingHeight < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 168
      @text = 'MISSING_HEIGHT'
      @description = 'Neuvedena výška'
      @type = :error
    end

    class MissingWidth < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 169
      @text = 'MISSING_WIDTH'
      @description = 'Neuvedena šířka'
      @type = :error
    end

    class MissingLength < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 170
      @text = 'MISSING_LENGTH'
      @description = 'Neuvedena délka'
      @type = :error
    end

    class PalettsNumberOutOfRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 171
      @text = 'MISSING_PALETTS_NUMBER'
      @description = 'Počet palet mimo povolený rozsah'
      @type = :error
    end

    class InvalidWeight < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 173
      @text = 'INVALID_WEIGHT'
      @description = 'Součet fyzických hmotností celé vícekusové zásilky mimo povolený rozsah'
      @type = :error
    end

    class InvalidDensity < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 174
      @text = 'INVALID_DENSITY'
      @description = 'Součet objemových hmotností celé vícekusové zásilky mimo povolený rozsah'
      @type = :error
    end

    class CODAmountOutOfRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 176
      @text = 'INVALID_AMOUNT'
      @description = 'Napočtená dobírka u hlavni zásilky je nad povolený rozsah'
      @type = :error
    end

    class CODAmountTooBig < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 177
      @text = 'INVALID_AMOUNT'
      @description = 'Limit pro uložení zásilky na Výdejním místě je pro Dobírku max. 50.000,- Kč.' \
                     ' Zásilka bude uložena na poště, která je Výdejnímu místu nadřízená.'
      @type = :error
    end

    class PriceTooBig < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 178
      @text = 'INVALID_PRICE'
      @description = 'Limit pro uložení zásilky na Výdejním místě je pro Udanou cenu a Dobírku max. 50.000,- Kč.' \
                     ' Zásilka bude uložena na poště, která je Výdejnímu místu nadřízená.'
      @type = :error
    end

    class PriceAndCODAmountTooBig < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 179
      @text = 'INVALID_PRICE_AND_AMOUNT'
      @description = 'Limit pro uložení zásilky na Výdejním místě je pro Udanou cenu a Dobírku max. 50.000,- Kč.' \
                     ' Zásilka bude uložena na poště, která je Výdejnímu místu nadřízená.'
      @type = :error
    end

    class InfoInvalidPhoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 182
      @text = 'INFO_INVALID_PHONE_NUMBER'
      @description = 'Neplatný formát telefonního čísla'
      @type = :info
    end

    class InfoInvalidEmail < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 183
      @text = 'INFO_INVALID_EMAIL'
      @description = 'Neplatný formát emailu'
      @type = :info
    end

    class InvalidPhoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 184
      @text = 'INVALID_PHONE_NUMBER'
      @description = 'Neplatný formát telefonního čísla'
      @type = :error
    end

    class InvalidEmail < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 185
      @text = 'INVALID_EMAIL'
      @description = 'Neplatný formát emailu'
      @type = :error
    end

    class MissingRequiredService4 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 186
      @text = 'MISSING_REQUIRED_SERVICE 4'
      @description = 'Musí být vybraná služba "Dobírka Pk A" !'
      @type = :error
    end

    class ServicesCombinationNotAllowed < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 187
      @text = 'INVALID_PREFIX'
      @description = 'Nepovolená kombinace doplňkových služeb'
      @type = :error
    end

    class MissingSenderEmail < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 188
      @text = 'MISSING_SENDER_EMAIL'
      @description = 'Neuveden povinný údaj- email odesílatele'
      @type = :error
    end

    class MissingRequiredMobileNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 189
      @text = 'MISSING_REQUIRED_MOBIL_NUMBER'
      @description = 'Není uveden povinný údaj - telefonní číslo nebo mobil adresáta'
      @type = :error
    end

    class InvalidSignNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 190
      @text = 'INVALID_SIGN_NUMBER'
      @description = 'Neuveden počet dokumentů určených k podpisu'
      @type = :error
    end

    class InvalidUseOfService36 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 191
      @text = 'INVALID_SERVICE_36'
      @description = 'Nepovolená kombinace adresy do Balíkomatu a služby 36 (Potvrzení dokumentace při dodání)'
      @type = :error
    end

    class InvalidUseOfService37 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 192
      @text = 'INVALID_SERVICE_37'
      @description = 'Nepovolená kombinace adresy do Balíkomatu a služby 37 (Ověření údajů při dodání)'
      @type = :error
    end

    class InvalidUseOfService38 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 193
      @text = 'INVALID_SERVICE_38'
      @description = 'Nepovolená kombinace adresy do Balíkomatu a služby 38 (Předání inf. z dod.)'
      @type = :error
    end

    class InvalidAddressAddresseeDocumentForParcelType < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 194
      @text = 'INVALID_ADDRESS_ADDRESSEE_DOCUMENT'
      @description = 'Zásilku tohoto typu nelze na uvedenou adresu adresáta dokumentů odeslat (obsahuje údaj Na poštu)'
      @type = :error
    end

    class MissingRequiredAddresseeDocument < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 195
      @text = 'MISSING_REQUIRED_ADDRESSEE_DOCUMENT'
      @description = 'Adresát dokumentů neuveden'
      @type = :error
    end

    class MissingRequiredMobileNumberOrEmail < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 196
      @text = 'MISSING_REQUIRED_MOBIL_OR_EMAIL'
      @description = 'Není uveden povinný údaj - mobilní telefonní číslo nebo email adresáta'
      @type = :error
    end

    class InvalidZPROOrderNumberFormat < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 197
      @text = 'INVALID_ZPRO_ORDER_NUMBER'
      @description = 'Nesprávný formát čísla objednávky ZPRO'
      @type = :error
    end

    class InvalidPartnerCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 198
      @text = 'INVALID_PARTNER_CODE'
      @description = 'Váš kód partnera neodpovídá zadanému kódu objednávky'
      @type = :error
    end

    class NotExistingOrderNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 199
      @text = 'INVALID_ORDER_NUMBER'
      @description = 'Neexistující číslo objednávky'
      @type = :error
    end

    class CanceledOrderNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 200
      @text = 'INVALID_ORDER_NUMBER'
      @description = 'Objednávka s tímto číslem byla stornována'
      @type = :error
    end

    class AlreadyAssignedOrderNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 201
      @text = 'INVALID_ORDER_NUMBER'
      @description = 'K číslu objednávky již existuje přiřazená zásilka, číslo objednávky nelze použít'
      @type = :error
    end

    class InvalidAmount < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 202
      @text = 'INVALID_AMOUNT'
      @description = 'Dobírková částka je vyšší než celková cena objednávky'
      @type = :error
    end

    class MissingRequiredZPROOrderNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 203
      @text = 'MISSING_REQUIRED_ZPRO_ORDER_NUMBER'
      @description = 'Neuvedeno číslo objednávky ZPRO'
      @type = :error
    end

    class VariableSymbolIsNotNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 204
      @text = 'INVALID_VS_PARCEL'
      @description = 'Variabilní symbol není číslo'
      @type = :error
    end

    class ParcelCodeNotInAssignedRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 205
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Zadané ID zásilky není v rozmezí vaší přidělené číselné řady'
      @type = :error
    end

    class MissingParcelCustomGoods < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 206
      @text = 'MISSING_PARCEL_CUSTOM_GOODS'
      @description = 'Neuvedena data celní prohlášky'
      @type = :error
    end

    class MissingCategoryCustomDecalaration < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 207
      @text = 'MISSING_CATEGORY_CUSTOM_DECALARATION'
      @description = 'Neuvedena kategorie zásilky'
      @type = :error
    end

    class MissingCurrencyCustomDeclaration < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 208
      @text = 'MISSING_CURRENCY_CUSTOM_DECALARATION' # or DECLARATION?
      @description = 'Neuvedena měna celní hodnoty'
      @type = :error
    end

    class CustomGoodQuantityOutOfRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 209
      @text = 'INVALID_QUANTITY_CUSTOM_GOOD'
      @description = 'Množství celního obsahu mimo povolený rozsah'
      @type = :error
    end

    class MissingQuantityCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 210
      @text = 'MISSING_QUANTITY_CUSTOM_GOOD'
      @description = 'Neuvedeno množství celního obsahu'
      @type = :error
    end

    class WeightCustomGoodOutOfRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 211
      @text = 'INVALID_WEIGHT_CUSTOM_GOOD'
      @description = 'Hmotnost celního obsahu mimo povolený rozsah'
      @type = :error
    end

    class MissingWeightCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 212
      @text = 'MISSING_WEIGHT_CUSTOM_GOOD'
      @description = 'Neuvedena hmotnost celního obsahu'
      @type = :error
    end

    class MissingPriceCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 213
      @text = 'MISSING_PRICE_CUSTOM_GOOD'
      @description = 'Neuvedena celní hodnota položky'
      @type = :error
    end

    class MissingIsoCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 214
      @text = 'MISSING_ISO_CUSTOM_GOOD'
      @description = 'Neuvedena země původu zboží'
      @type = :error
    end

    class MissingHsCodeCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 215
      @text = 'MISSING_HS_CODE_CUSTOM_GOOD'
      @description = 'Neuveden tarifní kód'
      @type = :error
    end

    class MissingContentCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 216
      @text = 'MISSING_CONTENT_CUSTOM_GOOD'
      @description = 'Neuveden popis obsahu zboží'
      @type = :error
    end

    class InvalidPriceCurrencyAccordance < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 217
      @text = 'INVALID_PRICE_CURRENCY'
      @description = 'Nesouhlasí měna udané ceny'
      @type = :error
    end

    class InvalidAmountCurrency < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 218
      @text = 'INVALID_AMOUNT_CURRENCY'
      @description = 'Nesouhlasí měna dobírky'
      @type = :error
    end

    class MissingAddresseeZipCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 219
      @text = 'MISSING_ADDRESSEE_ZIP_CODE'
      @description = 'PSČ adresáta musí být vyplněno'
      @type = :error
    end

    class MissingAddresseeCity < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 220
      @text = 'MISSING_ADDRESSEE_CITY'
      @description = 'Obec adresáta musí být vyplněna'
      @type = :error
    end

    class InvalidWeightCustomGoodSummary < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 221
      @text = 'INVALID_WEIGHT_CUSTOM_GOOD_SUMMARY'
      @description = 'Celková hmotnost zboží je vyšší než hmotnost uvedená u zásilky'
      @type = :error
    end

    class MissingParcelCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 222
      @text = 'MISSING_PARCEL_CUSTOM_GOOD'
      @description = 'Neuvedena zásilka k položkám obsahu zboží'
      @type = :error
    end

    class WeightIsOutOfRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 223
      @text = 'INVALID_WEIGHT'
      @description = 'Váhové rozmezí je mimo povolený rozsah'
      @type = :error
    end

    class InvalidOrderNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 224
      @text = 'INVALID_ORDER_NUMBER'
      @description = 'Číslo objednávky nelze použít, ještě nedošlo k jejímu odeslání'
      @type = :error
    end

    class InvalidPrefixAccordance < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 225
      @text = 'INVALID_PREFIX'
      @description = 'Nesouhlasí typ zásilky s typem produktu dané dávky'
      @type = :error
    end

    class InvalidContentCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 226
      @text = 'INVALID_CONTENT_CUSTOM_GOOD'
      @description = 'Celní hodnota položky je mimo povolený rozsah'
      @type = :error
    end

    class InvalidCustomGoodNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 227
      @text = 'INVALID_CUSTOM_GOOD_NUMBER'
      @description = 'Počet položek celního obsahu mimo povolený rozsah'
      @type = :error
    end

    class MissingRequiredVoucherPrice < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 228
      @text = 'MISSING_REQUIRED_VOUCHER_PRICE'
      @description = 'Neuvedena částka'
      @type = :error
    end

    class MissingRequiredPayday < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 230
      @text = 'MISSING_REQUIRED_PAYDAY'
      @description = 'Termín výplaty není uveden'
      @type = :error
    end

    class InvalidPayday < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 231
      @text = 'INVALID_PAYDAY'
      @description = 'Termín výplaty je mimo povolené rozmezí 365 dní'
      @type = :error
    end

    class OverenoVecerniDorucovani < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 232
      @text = 'overenoVecerniDorucovani' # WTF?
      @description = 'Termín výplaty není platné datum'
      @type = :error
    end

    class MissingRequiredService3XTrinity < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 240
      @text = 'MISSING_REQUIRED_SERVICE 3/32/33'
      @description = 'Neuvedena povinná služba 3 ani 32 ani 33'
      @type = :error
    end

    class MissingRequiredService10 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 241
      @text = 'MISSING_REQUIRED_SERVICE_10'
      @description = 'Neuvedena služba 10'
      @type = :error
    end

    class MissingRequiredService1AB < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 242
      @text = 'MISSING_REQUIRED_SERVICE 1A/1B'
      @description = 'Neuvedena povinná služba 1A ani 1B'
      @type = :error
    end

    class MissingHandlingInstructions < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 243
      @text = 'MISSING_REQUIRED_SERVICE'
      @description = 'Neuvedeny dispozice pro nakládání se zásilkou'
      @type = :error
    end

    class MissingReturnInstructions < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 243
      @text = 'MISSING_REQUIRED_SERVICE'
      @description = 'Neuveden způsob vrácení zásilky (ekonom./let.)'
      @type = :error
    end

    class MissingReturnNumberDays < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 245
      @text = 'MISSING_RETURN_NUMBER_DAYS'
      @description = 'Neuveden počet dní pro vrácení zásilky'
      @type = :error
    end

    class InvalidReturnNumberDays < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 246
      @text = 'INVALID_RETURN_NUMBER_DAYS'
      @description = 'Počet dní pro vrácení zásilky mimo povolený rozsah'
      @type = :error
    end

    class InvalidAddressForBalikovna < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 247
      @text = 'INVALID_ADRESS'
      @description = 'Nepovolená provozovna pro adresu typu Balíkovna'
      @type = :error
    end

    class AddressAllowedForBalikovnaOnly < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 248
      @text = 'INVALID_ADRESS'
      @description = 'Adresa je vhodná pouze pro produkt balík do Balíkovny'
      @type = :error
    end

    class MissingRequiredAddresseeEmail < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 250
      @text = 'MISSING_REQUIRED_EMAIL'
      @description = 'Není uveden povinný údaj - email adresáta'
      @type = :error
    end

    class MissingRequiredFirstNameAddresseeDocument < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 252
      @text = 'MISSING_REQUIRED_FIRST_NAME_ADDRESSEE_DOCUMENT'
      @description = 'Neuvedeno jméno adresáta dokumentů'
      @type = :error
    end

    class InfoInexactAddress < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 253
      @text = 'INFO_INEXACT_ADDRESS'
      @description = 'Nepřesná (nejednoznačná) adresa'
      @type = :info
    end

    class InvalidParcelBarcode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 254
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Chybné ID čárového kódu'
      @type = :error
    end

    # WHAT! AGAIN?
    class InvalidParcelBarcodeDuplicate < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 255
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Chybné ID čárového kódu'
      @type = :error
    end

    class DuplicateDuplicateParcelCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 256
      @text = 'DUPLICATE_PARCEL_CODE' # here we go again
      @description = 'Duplicitní ID čárového kódu'
      @type = :error
    end

    class AddressSuitableForLocalDelivery < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 257
      @text = 'INVALID_ADRESS' # no kidding! Like 6 times same text?
      @description = 'Adresa je vhodná pouze pro vnitrostátní zásilky'
      @type = :error
    end

    class MissingVariableSymbolDuplicate < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 258
      @text = 'MISSING_VS'
      @description = 'Nevyplněn variabilní symbol'
      @type = :error
    end

    class AddresseeCityRequired < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 259
      @text = 'MISSING_ADDRESSEE_CITY'
      @description = 'Není uveden povinný údaj - město adresáta'
      @type = :error
    end

    class MissingAddresseeStreet < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 260
      @text = 'MISSING_ADDRESSEE_STREET'
      @description = 'Není uveden povinný údaj – ulice adresáta'
      @type = :error
    end

    class MissingSizeCategory < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 261
      @text = 'MISSING_SIZE_CATEGORY'
      @description = 'Neuvedena rozměrová kategorie zásilky'
      @type = :error
    end

    class PriceOutOfRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 262
      @text = 'INVALID_PRICE'
      @description = 'Udaná cena mimo povolený rozsah'
      @type = :error
    end

    class InfoSpecialPackagingRequest < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 263
      @text = 'INFO_SPECIAL_PACKAGING_REQUEST'
      @description = 'Pozor – požadavek na speciální balení zásilky'
      @type = :info
    end

    class PriceTooLow < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 264
      @text = 'INVALID_PRICE'
      @description = 'Službu Cenný obsah je možné zvolit až od 10 tis. Kč'
      @type = :error
    end

    class MissingAddressee < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 300
      @text = 'MISSING_ADDRESSEE'
      @description = 'Adresát neuveden'
      @type = :error
    end

    class InfoCityChanged < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 301
      @text = 'INFO_CITY_CHANGED'
      @description = 'V adrese byl upraven údaj "obec" dle zadaného psč'
      @type = :info
    end

    class AddressIsNotValidForSubject < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 302
      @text = 'MISSING_ADDRESS'
      @description = 'Nepovolená kombinace adresy a subjektu'
      @type = :error
    end

    class InfoInvalidBirthDay < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 303
      @text = 'INFO_INVALID_BIRTH_DAY'
      @description = 'Neplatný formát data narození'
      @type = :info
    end

    class InfoInvalidMobilePhoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 304
      @text = 'INFO_INVALID_MOBIL_NUMBER'
      @description = 'Mobil - neplatné telefonní číslo'
      @type = :info
    end

    class InfoInvalidTelephoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 305
      @text = 'INFO_INVALID_TELEPHONE_NUMBER'
      @description = 'Telefon - neplatné telefonní číslo'
      @type = :info
    end

    class InfoInvalidPrefixAccount < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 306
      @text = 'INFO_INVALID_PREFIX_ACCOUNT'
      @description = 'Předčíslí není číslo'
      @type = :info
    end

    class InfoInvalidAccount < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 307
      @text = 'INFO_INVALID_ACCOUNT'
      @description = 'Účet není číslo'
      @type = :info
    end

    class InfoInvalidBankCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 308
      @text = 'INFO_INVALID_BANK_CODE'
      @description = 'Banka není číslo'
      @type = :info
    end

    class InvalidostCodeOrCity < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 309
      @text = 'INVALID_ADDRESS'
      @description = 'Chybná adresa - neexistující PSČ nebo obec'
      @type = :error
    end

    class InvalidTypePrefix < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 310
      @text = 'INVALID_PREFIX'
      @description = 'Neplatný typ zásilky'
      @type = :error
    end

    class InvalidParcelTypeForID < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 311
      @text = 'INVALID_PREFIX'
      @description = 'Nesouhlasí typ zásilky s ID zásilky'
      @type = :error
    end

    class InfoCancelService29 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 312
      @text = 'INFO_CANCEL_SERVICE_29'
      @description = 'Zrušena služba 29 - nepovolená služba pro typ adresy poste restante'
      @type = :info
    end

    class InfoInvalidWeight < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 313
      @text = 'INFO_INVALID_WEIGHT'
      @description = 'Hmotnost není číslo'
      @type = :info
    end

    class InfoInvalidPrice < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 314
      @text = 'INFO_INVALID_PRICE'
      @description = 'Udaná cena není číslo'
      @type = :info
    end

    class InfoInvalidCODAmount < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 315
      @text = 'INFO_INVALID_AMOUNT'
      @description = 'Dobírka není číslo'
      @type = :info
    end

    class InvalidCODCurrencyAccordance < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 316
      @text = 'INVALID_AMOUNT_CURRENCY'
      @description = 'Nesouhlasí měna dobírkove částky'
      @type = :error
    end

    class InfoInvalidSpecificSymbol < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 317
      @text = 'INFO_INVALID_SPEC_SYMBOL'
      @description = 'Specifický symbol není číslo'
      @type = :info
    end

    class InfoCancelService27 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 318
      @text = 'INFO_CANCEL_SERVICE_27'
      @description = 'Zrušena služba 27 - nepovolená služba pro adresáta s PSČ Výdejního místa'
      @type = :info
    end

    class InvalidService18 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 319
      @text = 'INVALID_SERVICE_18'
      @description = 'Nepovolena kombinace adresy a služby Doručení v Sobotu'
      @type = :error
    end

    class InvalidService19 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 320
      @text = 'INVALID_SERVICE_19'
      @description = 'Nepovolena kombinace adresy a služby Doručení v Neděli/sv'
      @type = :error
    end

    class InfoCancelService30 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 321
      @text = 'INFO_CANCEL_SERVICE_30'
      @description = 'Zrušena služba 30 - nepovolená služba u produktu Balík Do ruky nad 30kg'
      @type = :info
    end

    class InfoCancelService31 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 322
      @text = 'INFO_CANCEL_SERVICE_31'
      @description = 'Zrušena služba 31 - nepovolená služba u produktu Balík Do ruky nad 30kg'
      @type = :info
    end

    class InfoCancelService47 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 323
      @text = 'INFO_CANCEL_SERVICE_47'
      @description = 'Zrušena služba 47 - nepovolená služba u produktu Balík Do ruky do 30kg'
      @type = :info
    end

    class InfoService29And47 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 324
      @text = 'INFO_SERVICE_29+47'
      @description = 'Zásilku s výškou nad 150cm nelze podat jako Balík Do ruky se sl.47,' \
                     ' ale musí být využit Balík Nadrozměr v kategorii NZ 2'
      @type = :info
    end

    class InfoCancelService34InvalidPhoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 325
      @text = 'INFO_CANCEL_SERVICE_34'
      @description = 'Zrušena služba 34, nesprávný formát telefonního čísla'
      @type = :info
    end

    class InfoCancelService45InvalidPhoneNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 326
      @text = 'INFO_CANCEL_SERVICE_45'
      @description = 'Zrušena služba 45, nesprávný formát telefonního čísla nebo emailu'
      @type = :info
    end

    class MissingRequiredEmail < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 327
      @text = 'MISSING_REQUIRED_EMAIL'
      @description = 'Není uveden povinný údaj - email adresáta'
      @type = :error
    end

    class InfoCancelService25 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 328
      @text = 'INFO_CANCEL_SERVICE_25'
      @description = 'Zrušena služba 25 - neuvedena povinná služba 24 k této službě'
      @type = :info
    end

    class MissingRequiredParcelCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 329
      @text = 'MISSING_REQUIRED_PARCEL_CODE'
      @description = 'Neuvedeno ID zásilky'
      @type = :error
    end

    class ParcelCodeNotAllowed < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 330
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Nepovolené ID zásilky'
      @type = :error
    end

    class MissingPalettsNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 331
      @text = 'MISSING_PALETTS_NUMBER'
      @description = 'Neuveden počet palet'
      @type = :error
    end

    class InfoCancelPalettsNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 332
      @text = 'INFO_CANCEL_PALETTS_NUMBER'
      @description = 'Počet palet není celé číslo'
      @type = :info
    end

    class InfoCancelWidth < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 333
      @text = 'INFO_CANCEL_WIDTH'
      @description = 'Šířka není celé číslo'
      @type = :info
    end

    class InfoCancelHeight < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 334
      @text = 'INFO_CANCEL_HEIGHT'
      @description = 'Výška není celé číslo'
      @type = :info
    end

    class InfoCancelLength < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 335
      @text = 'INFO_CANCEL_LENGTH'
      @description = 'Délka není celé číslo'
      @type = :info
    end

    class MissingRequiredPrice < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 336
      @text = 'MISSING_REQUIRED_PRICE'
      @description = 'Neuvedena částka udané ceny'
      @type = :error
    end

    class InvalidAmountType < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 337
      @text = 'INVALID_AMOUNT_TYPE'
      @description = 'Neuveden typ dobírky'
      @type = :error
    end

    class InfoCancelVSVoucher < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 338
      @text = 'INFO_CANCEL_VS_VOUCHER'
      @description = 'Variabilní symbol poukázky není číslo'
      @type = :info
    end

    class InvalidServiceCombination < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 339
      @text = 'INVALID_SERVICE_COMBINATION'
      @description = 'Nepovolená kombinace doplňkových služeb službyZak'
      @type = :error
    end

    class InvalidMRNCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 340
      @text = 'INVALID_MRN_CODE'
      @description = 'neplatný kód MRN'
      @type = :error
    end

    class InfoCancelService34 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 341
      @text = 'INFO_CANCEL_SERVICE_34'
      @description = 'Zrušena služba 34, nesprávný formát telefonního čísla'
      @type = :info
    end

    class InfoCancelService46 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 342
      @text = 'INFO_CANCEL_SERVICE_46'
      @description = 'Zrušena služba 46, nesprávný formát emailu'
      @type = :info
    end

    class InfoCancelService45 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 343
      @text = 'INFO_CANCEL_SERVICE_45'
      @description = 'Zrušena služba 45, nesprávný formát telefonního čísla nebo emailu'
      @type = :info
    end

    class MissingRequiredAddresseeDocumentDuplicate < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 344
      @text = 'MISSING_REQUIRED_ADDRESSEE_DOCUMENT'
      @description = 'Adresát dokumentů neuveden'
      @type = :error
    end

    class InvalidAddressAddresseeDocumentWrongCity < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 345
      @text = 'INVALID_ADDRESS_ADDRESSEE_DOCUMENT'
      @description = 'Chybná adresa adresáta dokumentů - neexistující PSČ nebo obec'
      @type = :error
    end

    class InvalidAddressAddresseeDocumentObjectNotFound < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 346
      @text = 'INVALID_ADDRESS_ADDRESSEE_DOCUMENT'
      @description = 'Nepřesná adresa adresáta dokumentů - nenalezen objekt'
      @type = :error
    end

    class InfoCancelMobilePhoneOrEmailAddresseeDocument < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 347
      @text = 'INF0_CANCEL_MOBIL_OR_EMAIL_ADDRESSEE_DOCUMENT' # really `inf0` ?
      @description = 'Mobil - neplatné telefonní číslo nebo email ardesáta dokumentů'
      @type = :info
    end

    class InfoCancelCustCardNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 348
      @text = 'INFO_CANCEL_CUST_CARD_NUMBER'
      @description = 'Nesprávný formát zákaznické karty'
      @type = :info
    end

    class InfoCancelCustCardNumberAddresseeDocument < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 349
      @text = 'INFO_CANCEL_CUST_CARD_NUMBER_ADDRESSEE_DOCUMENT'
      @description = 'Nesprávný formát zákaznické karty ardesáta dokumentů'
      @type = :info
    end

    class InvalidZPROOrderNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 350
      @text = 'INVALID_ZPRO_ORDER_NUMBER'
      @description = 'Nesprávný formát čísla objednávky ZPRO'
      @type = :error
    end

    class InfoAddRequiredService75 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 351
      @text = 'INFO_ADD_REQUIRED_SERVICE_75'
      @description = 'Doplněna povinná služba 75 k číslu objednávky ZPRO'
      @type = :info
    end

    class InvalidPriceCurrency < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 352
      @text = 'INVALID_PRICE_CURRENCY'
      @description = 'Nesouhlasí měna udané ceny'
      @type = :error
    end

    class InvalidCategoryCustomDecalaration < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 353
      @text = 'INVALID_CATEGORY_CUSTOM_DECALARATION'
      @description = 'Nesprávný formát kategorie zásilky'
      @type = :error
    end

    class InvalidCurrencyCustomDecalaration < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 354
      @text = 'INVALID_CURRENCY_CUSTOM_DECALARATION'
      @description = 'Nesprávný formát měny celní hodnoty'
      @type = :error
    end

    class InvalidQuantityCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 355
      @text = 'INVALID_QUANTITY_CUSTOM_GOOD'
      @description = 'Nesprávný formát množství celního obsahu'
      @type = :error
    end

    class InvalidWeightCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 356
      @text = 'INVALID_WEIGHT_CUSTOM_GOOD'
      @description = 'Nesprávný formát hmotnosti celního obsahu'
      @type = :error
    end

    class InvalidPriceCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 357
      @text = 'INVALID_PRICE_CUSTOM_GOOD'
      @description = 'Nesprávný formát celní hodnota položky'
      @type = :error
    end

    class InvalidIsoCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 358
      @text = 'INVALID_ISO_CUSTOM_GOOD'
      @description = 'Neexistující země původu zboží'
      @type = :error
    end

    class InvalidIsoCustomGoodFormat < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 359
      @text = 'INVALID_ISO_CUSTOM_GOOD'
      @description = 'Nesprávný formát země původu zboží'
      @type = :error
    end

    class InvalidHsCodeCustomGood < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 360
      @text = 'INVALID_HS_CODE_CUSTOM_GOOD'
      @description = 'Nesprávný formát tarifního kódu'
      @type = :error
    end

    class MissingRequiredService4x < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 361
      @text = 'MISSING_REQUIRED_SERVICE_43/44'
      @description = 'Neuvedena povinná služba č. 43 nebo č. 44 k datům celní prohlášky'
      @type = :error
    end

    class InfoPriceIsNotNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 362
      @text = 'INFO_CANCEL_PRICE'
      @description = 'Částka není číslo'
      @type = :info
    end

    class InfoPriceIsTooBig < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 363
      @text = 'INFO_CANCEL_PRICE'
      @description = 'Příliš velká částka'
      @type = :info
    end

    class InfoCancelPersonalIdentificationNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 364
      @text = 'INFO_CANCEL_PERSONAL_IDENTIFICATION_NUMBER'
      @description = 'Neplatný formát rodného čísla'
      @type = :info
    end

    class InvalidAddressee < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 365
      @text = 'INVALID_ADDRESSEE'
      @description = 'Chybný adresát'
      @type = :error
    end

    class ResponsibleConsignmentNumberOutOfRange < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 366
      @text = 'INVALID_RESPONSIBLE_CONSIGNMENT_NUMBER'
      @description = 'Hodnota "počet odpovědních zásilek" je mimo povolený rozsah'
      @type = :error
    end

    class InvalidResponsibleConsignmentNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 367
      @text = 'INVALID_RESPONSIBLE_CONSIGNMENT_NUMBER'
      @description = 'Nesprávný formát počtu odpovědních zásilek'
      @type = :error
    end

    class ResponsibleConsignmentNumberCannotBeImported < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 368
      @text = 'INVALID_RESPONSIBLE_CONSIGNMENT_NUMBER'
      @description = 'Počet odpovědních zásilek při vyplnění ID zásilky nelze importovat'
      @type = :error
    end

    class InfoCancelService1ABForService40 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 369
      @text = 'INFO_CANCEL_SERVICE_1A/1B'
      @description = 'Zrušena služba 1A/1B - nepovolená ke službě 40'
      @type = :info
    end

    class InfoCancelService1AForService40 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 370
      @text = 'INFO_CANCEL_SERVICE_1A'
      @description = 'Zrušena služba 1A – nepovolená ke službě 40'
      @type = :info
    end

    class InfoCancelService1BForPostCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 371
      @text = 'INFO_CANCEL_SERVICE_1B'
      @description = 'Zrušena služba 1B – nepovolena k PSČ adresáta'
      @type = :info
    end

    class InvalidTareWeight < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 372
      @text = 'INVALID_TARE_WEIGHT'
      @description = 'Hmotnost obalu je mimo povolený rozsah'
      @type = :error
    end

    class InvalidNumberClosure < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 373
      @text = 'INVALID_NUMBER_CLOSURE'
      @description = 'Duplicitní číslo uzávěru'
      @type = :error
    end

    class DuplicitParcelCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 374
      @text = 'INVALID_PARCEL_CODE'
      @description = 'Duplicitní ID zásilky v rámci souboru'
      @type = :error
    end

    class InvalidTiming < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 375
      @text = 'INVALID_TIMING'
      @description = 'Nesprávný předstih podání'
      @type = :error
    end

    class InfoCancelService1AB < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 376
      @text = 'INFO_CANCEL_SERVICE_1A+1B'
      @description = 'Zrušena služba 1A a 1B - nepovolená kombinace doplňkových služeb'
      @type = :info
    end

    class InfoCancelService1B < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 377
      @text = 'INFO_CANCEL_SERVICE_1B'
      @description = 'Zrušena služba 1B'
      @type = :info
    end

    class InvalidPrefixCombination < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 378
      @text = 'INVALID_PREFIX_COMBINATION'
      @description = 'Zásilka je chybně přiřazena k id tiskové šablony'
      @type = :error
    end

    class ParcelDoesNotMeetTheRequirementsForm < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 379
      @text = 'PARCEL_DOES_NOT_MEET_THE_REQUIREMENTS_FORM'
      @description = 'Parametry zásilky nesplňují podmínky požadovaného formuláře'
      @type = :error
    end

    class NoContractServiceReturnReceipt < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 380
      @text = 'NO_CONTRACT_SERVICE_RETURN_RECEIPT'
      @description = 'K formuláři není sjednána smlouva ke službě Dodejka'
      @type = :error
    end

    class InfoCancelService1BAddService1A < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 381
      @text = 'INFO_CANCEL_SERVICE_1B_ADD_SERVICE_1A'
      @description = 'Služba 1B není povolena k PSČ adresáta, nahrazena službou 1A'
      @type = :info
    end

    class InfoCancelService1AForPostCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 382
      @text = 'INFO_CANCEL_SERVICE_1A'
      @description = 'Zrušena služba 1A – nepovolena k PSČ adresáta'
      @type = :info
    end

    class InvalidCustomerCardNumber < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 383
      @text = 'INVALID_CUSTOMER_CARD_NUMBER'
      @description = 'Chybné číslo zákaznické karty'
      @type = :error
    end

    class BadFormatReturnNumberDays < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 384
      @text = 'BAD_FORMAT_RETURN_NUMBER_DAYS'
      @description = 'Neplatný formát počtu dní pro vrácení zásilky'
      @type = :error
    end

    class InfoAddService1B < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 385
      @text = 'INFO_ADD_SERVICE_1B'
      @description = 'Přiřazena služba 1B Doruč. 13-19 hod'
      @type = :info
    end

    class InfoAddService1A < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 386
      @text = 'INFO_ADD_SERVICE_1A'
      @description = 'Přiřazena služba 1A Doruč. 8-14 hod'
      @type = :info
    end

    class InfoCancelService1AWith1B < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 387
      @text = 'INFO_CANCEL_SERVICE_1A'
      @description = 'Zrušena služba 1A Doruč. 8-14 hod - nepovolena se službou 1B'
      @type = :info
    end

    class InfoCancelService1BWith1A < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 388
      @text = 'INFO_CANCEL_SERVICE_1B'
      @description = 'Zrušena služba 1B Doruč. 13-19 hod - nepovolena se službou 1A'
      @type = :info
    end

    class InfoCancelService1V < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 389
      @text = 'INFO_CANCEL_SERVICE_1V'
      @description = 'Zrušena nepovolená služba 1V - Vrácení zboží'
      @type = :info
    end

    class InfoAddresseeToLong < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 390
      @text = 'INFO_ADDRESSEE_TO_LONG'
      @description = 'Adresát mimo rozsah 40 znaků pro přenos ke zpracování Pk B'
      @type = :info
    end

    class InfoMissingPartCityServiceDeliveryOnSundayOrHolidayMayNotBeRealized < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 391
      @text = 'INFO_MISSING_PART_CITY_SERVICE_DELIVERY_ON_SUNDAY/HOLIDAY_MAY_NOT_BE_REALIZED'
      @description = 'Neuvedena část obce - služba Garantovaný čas dodání v Ne/Sv nemusí být realizována'
      @type = :info
    end

    class InfoCancelService9 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 392
      @text = 'NFO_CANCEL_SERVICE_9'
      @description = 'Zrušena nepovolená služba 9 Prioritně'
      @type = :info
    end

    class InfoAddService9 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 393
      @text = 'INFO_ADD_SERVICE_9'
      @description = 'Přiřazena služba 9 Prioritně'
      @type = :info
    end

    class InfoCancelService1E < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 394
      @text = 'INFO_CANCEL_SERVICE_1E'
      @description = 'Zrušena služba 1E - neuveden kontaktní údaj adresáta'
      @type = :info
    end

    class InfoCancelService5B < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 395
      @text = 'INFO_CANCEL_SERVICE_5B'
      @description = 'Zrušena služba 5B - neuveden kontaktní údaj adresáta'
      @type = :info
    end

    class InfoCancelService5C < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 396
      @text = 'INFO_CANCEL_SERVICE_5C'
      @description = 'Zrušena služba 5C - neuveden kontaktní údaj adresáta'
      @type = :info
    end

    class InfoCancelService5D < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 397
      @text = 'INFO_CANCEL_SERVICE_5D'
      @description = 'Zrušena služba 5D - neuveden kontaktní údaj adresáta'
      @type = :info
    end

    class InfoCancelService5BAnd5C < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 398
      @text = 'INFO_CANCEL_SERVICE_5B_AND_5C'
      @description = 'Zrušena služba 5B a 5C --nepovolená kombinace doplňkových služeb'
      @type = :info
    end

    class InfoCancelService5BAnd5D < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 399
      @text = 'INFO_CANCEL_SERVICE_5B_AND_5D'
      @description = 'Zrušena služba 5B a 5D - nepovolená kombinace doplňkových služeb'
      @type = :info
    end

    class InfoCancelService5CAnd5D < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 400
      @text = 'INFO_CANCEL_SERVICE_5C_AND_5D'
      @description = 'Zrušena služba 5C a 5D - nepovolená kombinace doplňkových služeb'
      @type = :info
    end

    class InfoInvalidCategoryCustomDecalaration < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 401
      @text = 'INFO_INVALID_CATEGORY_CUSTOM_DECALARATION'
      @description = 'Uvedena nepovolená kategorie zásilky - nahrazena kategorií Dokumenty'
      @type = :info
    end

    class InvalidSubisoCountry < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 402
      @text = 'INVALID_SUBISO_COUNTRY'
      @description = 'Neexistující nebo nesprávný členský stát'
      @type = :error
    end

    class NoContractService41 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 403
      @text = 'NO_CONTRACT_SERVICE_41'
      @description = 'Pro tech. číslo a produkt nesjednána služba Bezdokladová dobírka'
      @type = :error
    end

    class InvalidServicesForDimensions < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 404
      @text = 'INVALID_PREFIX'
      @description = 'Nepovolená kombinace doplňkových služeb – rozměr zásilky'
      @type = :error
    end

    class InvalidPrefixForDimensionsAndFragile < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 405
      @text = 'INVALID_PREFIX'
      @description = 'Nepovolená kombinace doplňkových služeb – rozměr zásilky a sl.11 (Křehce)'
      @type = :error
    end

    class InfoAddService1D < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 406
      @text = 'INFO_ADD_SERVICE_1D'
      @description = 'Přiřazena služba 1D – cenný obsah'
      @type = :info
    end

    class InfoCancelService1D < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 407
      @text = 'INFO_CANCEL_SERVICE_1D'
      @description = 'Zrušena služba 1D'
      @type = :info
    end

    class InfoAddressWasModified < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 408
      @text = 'INFO_ADDRESS_WAS_MODIFIED'
      @description = 'Adresa není přesná, byla upravena'
      @type = :info
    end

    class InvalidAddresseeZipCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 409
      @text = 'INVALID_ADDRESSE_ZIP_CODE'
      @description = 'Chybný formát PSČ adresáta'
      @type = :error
    end

    class InvalidAddresseeCountry < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 410
      @text = 'INVALID_ADDRESSEE'
      @description = 'nesouhlasí země určení s VDD'
      @type = :error
    end

    class IncorrectParcelCount < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 411
      @text = 'INCORECT_NUMBER_OF_RECEIVED_PARCELS'
      @description = 'Nepořízeny všechny zásilky k VDD'
      @type = :error
    end

    class InfoHsCodeWasModified < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 412
      @text = 'INFO_HS_CODE_WAS_MODIFIED'
      @description = 'Upraven tarifní kód na max. počet 6-ti znaků'
      @type = :info
    end

    class InvalidCategoryOfCustomDeclaration < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 413
      @text = 'INVALID_CATEGORY_CUSTOM_DECALARATION' # not my typo, it is from official API docs
      @description = 'Nepovolená kategorie zásilky – dárek – jde pouze o zboží/komodity zasílané mezi dvěma fyzickými osobami'
      @type = :error
    end

    class MissingDocumentType < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 414
      @text = 'MISSING_DOCUMENT_TYPE'
      @description = 'Neuveden typ dokumentu'
      @type = :error
    end

    class DuplicitDocumentType < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 415
      @text = 'DUPLICIT_DOCUMENT_TYPE'
      @description = 'Duplicitní typ dokumentu'
      @type = :error
    end

    class MissingLocationName < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 416
      @text = 'MISSING_LOCATION_NAME'
      @description = 'Název podacího místa musí být vyplněn'
      @type = :error
    end

    class InfoInvalidIcFormat < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 417
      @text = 'INFO_INVALID_IC_FORMAT'
      @description = 'Nesprávný formát IČ'
      @type = :info
    end

    class InfoInvalidIcFormatOfAddresseeDocument < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 418
      @text = 'INFO_INVALID_IC_FORMAT_ADDRESSEE_DOCUMENT'
      @description = 'Nesprávný formát IČ adresáta dokumentů'
      @type = :info
    end

    class InvalidHsCode < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 419
      @text = 'INVALID_HS_CODE'
      @description = 'Neplatný tarifní kód'
      @type = :error
    end

    class InvalidCustomGoodsContent < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 420
      @text = 'INVALID_CONTENT_CUSTOM_GOOD'
      @description = 'Neplatný popis celního obsahu'
      @type = :error
    end

    class InfoHsCodeWasModified < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 421
      @text = 'INFO_HS_CODE_WAS_MODIFIED'
      @description = 'Tarifní kód upraven dle popisu celního obsahu'
      @type = :info
    end

    class InfoCustomGoodsContentWasModified < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 422
      @text = 'INFO_CONTENT_CUSTOM_GOOD_WAS_MODIFIED'
      @description = 'Popis celního obsahu upraven dle tarifního kódu'
      @type = :info
    end

    class InfoNonexistingZipCodeWasReplacedByConstant < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 423
      @text = 'INFO_NON_EXISTENT_ZIP_CODE_REPLACED'
      @description = 'Neexistující PSČ nahrazeno konstantou'
      @type = :info
    end

    class InfoService40CanceledDueMissingContactToAddressee < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 424
      @text = 'INFO_CANCEL_SERVICE_40'
      @description = 'Zrušena služba 40 - neuveden kontaktní údaj adresáta'
      @type = :info
    end

    class InfoService29CanceledDueMissingContactToAddressee < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 425
      @text = 'INFO_CANCEL_SERVICE_29'
      @description = 'Zrušena dopl. sl. 29 – neuveden kontaktní údaj'
      @type = :info
    end

    class InfoService40CanceledNotAllowedTogetherWithService29 < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 426
      @text = 'INFO_CANCEL_SERVICE_40'
      @description = 'Zrušena služba 40 – nepovolena se sl. 29'
      @type = :info
    end

    class InfoService40CanceledPackageIsPosteRestante < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 427
      @text = 'INFO_CANCEL_SERVICE_40'
      @description = 'Zrušena služba 40 – zásilka Poste restante'
      @type = :info
    end

    class InfoService7KCancelledNotArrangedForClient < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 428
      @text = 'INFO_CANCEL_SERVICE_7K'
      @description = 'Zrušena služba 7K - nesjednaná služba pro zákaznické řešení'
      @type = :info
    end

    class InfoAvizoServiceAppended < CzechPostB2bClient::ResponseCodes::BaseCode
      @code = 429
      @text = 'INFO_NOTIFICIATON_WAS_MODIFIED'
      @description = 'Služba avizování přiřazena dle kontaktních údajů'
      @type = :info
    end

    # must be at end to collect all classes defined before
    def self.all_classes
      base_class = CzechPostB2bClient::ResponseCodes::BaseCode
      ObjectSpace.each_object(base_class.singleton_class).reject { |c| c == base_class }
    end

    def self.new_by_code(code, details = '')
      klass = all_classes.detect { |k| k.code == code }
      raise "ResponseCode with code: #{code}  is unknown!" unless klass

      klass.new(details)
    end
  end
end
