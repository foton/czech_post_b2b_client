# frozen_string_literal: true

# rubocop:disable Layout/LineLength

# Hopefully complete list of services which can be assigned to parcels
# It is hard to get list of current services and even harder to find out what does they mean (so You pick right name in English).
# They have SAME CODES! for different services (depending on which parcel You send).
# Or even better (worse?), they have service A and service B and service C which is actually "A and B". Strange in situation when You can assign as many services  as You want.

# source: https://www.postaonline.cz/podanionline/ePOST-dokumentace/20prilohy.html and older one
# Old services are commented out
# Comments at end of line mostly describes which type of parcels can 'afford' such service
#
# Do not miss `CzechPostB2bClient::PostServices.all_classes` method,
# it has to be at end of module to work properly
module CzechPostB2bClient
  module PostServices
    class Base
      class << self
        # CODE is not UNIQUE!
        attr_reader :code, :abbreviation, :description
      end
    end

    class ParcelSizeS < Base
      @code = 'S'
      @abbreviation = 'S'
      @description = 'Velikost S (nejdelší strana do 35cm)'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Cenný balík ((B, BD, BB, V, VD, VV) ; EMS (EE) ; Doporučený balíček (BA) ; Balík Expres (BE) ; Obyčejný balík (O)
    end

    class ParcelSizeM < Base
      @code = 'M'
      @abbreviation = 'M'
      @description = 'Velikost M (nejdelší strana do 50cm)'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Cenný balík ((B, BD, BB, V, VD, VV) ; EMS (EE) ; Doporučený balíček (BA) ; Balík Expres (BE) ; Obyčejný balík (O)
    end

    class ParcelSizeL < Base
      @code = 'L'
      @abbreviation = 'L'
      @description = 'Velikost L (nejdelší strana do 100cm)'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Cenný balík ((B, BD, BB, V, VD, VV) ; EMS (EE) ; Doporučený balíček (BA) ; Obyčejný balík (O)
    end

    class ParcelSizeXL < Base
      @code = 'XL'
      @abbreviation = 'XL'
      @description = 'Velikost XL (nejdelší strana do 240cm)'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Cenný balík ((B, BD, BB, V, VD, VV) ; Obyčejný balík (O) |
    end

    class DeliverToAdresseeOnly < Base
      @code = '1'
      @abbreviation = 'VZ'
      @description = 'Do vlastních rukou'
      # ; Doporučené zásilky (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class DeliverToAdresseePersonOnly < Base
      @code = '8'
      @abbreviation = 'VR'
      @description = 'Do vlastních rukou výhradně jen adresáta'
      # ; Doporučené zásilky (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; MZ Cenné psaní (VL) ; MZ Doporučené zásilky (RR) |
    end

    class ForenoonDelivery < Base
      @code = '1A'
      @abbreviation = 'PD'
      @description = 'Doruč. 8-14 hod'
      # ; Balík Do ruky (DR, DV) ; Balík Komplet (BP) |
    end

    class AfternoonDelivery < Base
      @code = '1B'
      @abbreviation = 'PO'
      @description = 'Doruč. 13-19 hod'
      # ; Balík Do ruky (DR, DV) ; Balík Komplet (BP) |
    end

    class ValuableContent < Base
      @code = '1D'
      @abbreviation = 'CO'
      @description = 'Cenný obsah'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV) |
    end

    class EconomyDelivery < Base
      @code = '1K'
      @abbreviation = 'EK'
      @description = 'Ekonomický režim dodání'
      # ; Obyčejné psaní ; Obyčejné psaní standard ; Doporučené psaní (RR) ; Doporučené psaní standard (RR) ; Úřední psaní (RR) ; Úřední psaní standard (RR) ; Firemní psaní doporučeně (RR) ; Firemní psaní ; Zapsaná listovní zásilka (RJ) ; Nezapsaná listovní zásilka-obyčejné psaní |
    end

    # class TargetedLeaflet < Base
    #   @code = '1L'
    #   @abbreviation = ''
    #   @description = 'Cílený leták'
    #   # ; RIPM |Roznáška informačních/propagačních materiálů (RIPM)
    # end

    class NonStandardPackage < Base
      @code = '1N'
      @abbreviation = 'NR'
      @description = 'Nestandard'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Do Balíkovny (NB) ; Balík Expres (BE) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; Doporučený balíček (BA) ; Obyčejný balík (O) |
    end

    class DepositFor7Days < Base
      @code = '12'
      @abbreviation = 'U7'
      @description = 'Uložit 7 dnů'
      # ; Doporučené zásilky (RR) |
    end

    class DepositFor10WorkingDays < Base
      @code = '1U'
      @abbreviation = 'UXP'
      @description = 'Uložit 10 prac.dnů'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Cenné psaní (VL) ; Doporučený balíček (BA) ; Úřední psaní (RR) |
    end

    class DoNotDeposit < Base
      @code = '20'
      @abbreviation = 'NU'
      @description = 'Neukládat'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; Obyčejný balík (O) |
    end

    class DepositFor3Days < Base
      @code = '21'
      @abbreviation = 'U3'
      @description = 'Uložit 3 dny'
      # ; Doporučené zásilky (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class DepositFor10Days < Base
      @code = '22'
      @abbreviation = 'UX'
      @description = 'Uložit 10 dnů'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class DepositFor90Days < Base
      @code = '25'
      @abbreviation = ''
      @description = 'Uložit 90 dnů'
      # ; Doporučené zásilky (RT) |
    end

    class ReturnOfGoods < Base
      @code = '1V'
      @abbreviation = ''
      @description = 'Vrácení zboží'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) |
    end

    # class MoneyOrder < Base
    #   @code = '2'
    #   @abbreviation = ''
    #   @description = 'Složenka PS'
    #   # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    # end

    class CertificateOfDelivery < Base
      @code = '3'
      @abbreviation = 'D'
      @description = 'Dodejka'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; Standardní balík (CS) ; MZ Cenný balík (CV) ; MZ Cenné psaní (VL) ; MZ Doporučené zásilky (RR) |
    end

    class CashOnDeliveryByPKA < Base
      @code = '4'
      @abbreviation = 'DA'
      @description = 'Dobírka Pk A'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; Standardní balík (CS) ; MZ Cenný balík (CV) ; MZ Cenné psaní (VL) ; MZ Doporučené zásilky (RR) |
    end

    class CashOnDeliveryInternational < Base
      @code = '4'
      @abbreviation = ''
      @description = 'MZ Dobírka'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; Standardní balík (CS) ; MZ Cenný balík (CV) ; MZ Cenné psaní (VL) ; MZ Doporučené zásilky (RR) |
    end

    class CashOnDeliveryByPKC < Base
      @code = '5'
      @abbreviation = 'DC'
      @description = 'Dobírka Pk C'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class ResponseShipment < Base
      @code = '6'
      @abbreviation = 'OZ'
      @description = 'Odpovědní zásilka'
      # ; Doporučené zásilky (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV) ; Balík Na poštu (NP, NV, NA) ; Balík Nadrozměr (BN) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; Obyčejný balík (O) |
    end

    class ListedPrice < Base
      @code = '7'
      @abbreviation = 'UC'
      @description = 'Udaná cena'
      # ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Balík Komplet (BP) ; Balík Do balíkovny (NB) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; Obchodní balík do zahraničí (CE) ; MZ Cenný balík (CV) |
    end

    class PrioritaireByAir < Base
      @code = '9'
      @abbreviation = 'PR'
      @description = 'Prioritaire (letecky) – pouze u zásilek do zahraničí.'
      # ; MZ Doporučené zásilky (RR) ; MZ Cenné psaní (VL) ; Standardní balík (CS) ; MZ Cenný balík (CV) |
    end

    class CumbersomeParcel < Base
      @code = '10'
      @abbreviation = 'EN'
      @description = 'Neskladně'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Obchodní balík do zahraničí (CE) ; MZ Cenný balík (CV) ; Standardní balík (CS) |
    end

    class Fragile < Base
      @code = '11'
      @abbreviation = 'F'
      @description = 'Křehce'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; MZ Cenný balík (CV) ; Standardní balík (CS) |
    end

    class SubmissionReceiptCopy < Base
      @code = '13'
      @abbreviation = 'PS'
      @description = 'Opis podací stvrzenky'
    end

    class GuaranteedDeliveryTimeTo2PM < Base
      @code = '14'
      @abbreviation = 'EE'
      @description = 'Garantovaný čas dodání'
      # ; Balík Do ruky (DE) |
    end

    # class Diligently < Base
    #   @code = '15'
    #   @abbreviation = ''
    #   @description = 'Pilně'
    #   # prý dodání do druhého dne
    # end

    class DoNotExtendCollectionTime < Base
      @code = '16'
      @abbreviation = 'NL'
      @description = 'Neprodlužovat úložní dobu'
      # ; Doporučené zásilky (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class GuaranteedDeliveryTimeAtSaturday < Base
      @code = '18'
      @abbreviation = 'SB'
      @description = 'Garantované dodání v sobotu'
      # ; Balík Do ruky (DE) ; EMS (EE) |
    end

    class GuaranteedDeliveryTimeAtWeekend < Base
      @code = '19'
      @abbreviation = 'DN'
      @description = 'Doručení v neděli a svátky'
      # ; Balík Do ruky (DE) ; EMS (EE) |
    end

    class Missed < Base
      @code = '23'
      @abbreviation = 'Z'
      @description = 'Zmeškalá'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Komplet (BP) ; Balík Expres (BE) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class CompleteDelivery < Base
      @code = '24'
      @abbreviation = 'KD'
      @description = 'Komplexní doručení'
      # včetně rozbalení a kontroly obsahu' ; Balík Do ruky (DR, DV, DE) ; Balík Nadrozměr (BN) |
    end

    class OldApplianceRemoval < Base
      @code = '25'
      @abbreviation = 'O'
      @description = 'Odvoz starého spotřebiče'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Nadrozměr (BN) |
    end

    class DoNotResend < Base
      @code = '26'
      @abbreviation = 'ND'
      @description = 'Nedosílat'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) ; Obyčejný balík (O) |
    end

    class PickupByThirdPerson < Base
      @code = '27'
      @abbreviation = 'TO'
      @description = 'Vyzvednutí zásilky třetí osobou'
      # ; Balík Na poštu (NP, NV, NA) |
    end

    class DiscountForCollectiveShippment < Base
      @code = '28'
      @abbreviation = 'J'
      @description = 'Sleva J'
      # 15% (pouze pro více zásilek určených jednomu adresátovi)'   ; Balík Do ruky (DR, DV, DE) = '' #
    end

    class HeavyParcelDeliveryToHand < Base
      @code = '29'
      @abbreviation = 'DR30'
      @description = 'DR nad 30kg'
      # ; Balík Do ruky (DR, DV, DE) |
    end

    class ExtendedCollectionTime < Base
      @code = '30'
      @abbreviation = 'LH'
      @description = 'Prodloužení odběrní lhůty odesílatelem (16-31 dní)'
      # ; Doporučené zásilky (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; EMS (EE) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Cenný balík (B, BD, BB, V, VD, VV) ; Obyčejný balík (O) |
    end

    class PosteRestante < Base
      @code = '31'
      @abbreviation = 'PO'
      @description = 'Poste restante'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Komplet (BP) ; EMS (EE) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Cenný balík (B, BD, BB, V, VD, VV) ; Obyčejný balík (O) |
    end

    # WHY THESE? CAN WE JUST USE service 2 + 1  or 2 + 8?
    class CertificateOfDeliveryWithDeliverToAdresseeOnly < Base
      @code = '32'
      @abbreviation = 'DZ'
      @description = 'Dodejka a do vlastních rukou'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class CertificateOfDeliveryWithDeliverToAdresseePersonOnly < Base
      @code = '33'
      @abbreviation = 'DR'
      @description = 'Dodejka a do vlastních rukou výhradně jen adresáta'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    # Notify addressee
    class AddresseeAlertOfArrivalBySms < Base
      @code = '34'
      @abbreviation = 'AT'
      @description = 'Avízo adresát – SMS'
      # ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Komplet (BP) ; EMS (EE) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class AddresseeAlertOfArrivalBySmsAndEmail < Base
      @code = '45'
      @abbreviation = 'eA'
      @description = 'Avízo adresát – SMS + E-mail'
      # ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Komplet (BP) ; Balík Do balíkovny (NB) ; EMS (EE) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class AddresseeAlertOfArrivalByEmail < Base
      @code = '46'
      @abbreviation = 'AE'
      @description = 'Avízo adresát – E-mail'
      # ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Komplet (BP) ; Balík Do balíkovny (NB) ; EMS (EE) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    # MYSTERIOUS = { code: '35', abbreviation: '' }

    # SAME CODES, for different servise based on types of packages =>  HELL is comming
    class DepositIfAdresseeIsUnreachable < Base
      @code = '36'
      @abbreviation = 'UO'
      @description = 'Uložit-adresát neznámý'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) |
    end

    class DocumentsSignedAtDelivery < Base
      @code = '36'
      @abbreviation = 'POD'
      @description = 'Potvrzení dokumentace při dodání'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) |
    end

    class DoNotReturnLeaveItInMailbox < Base
      @code = '37'
      @abbreviation = 'SA'
      @description = 'Nevracet – vložit do schránky'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) |
    end

    class AddresseeVerificationOnDelivery < Base
      @code = '38'
      @abbreviation = 'OUD'
      @description = 'Ověření údajů při dodání'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) |
    end

    class DoNotPutIntoMailbox < Base
      @code = '38'
      @abbreviation = 'SN'
      @description = 'Nevkládat do schránky'
      # ; Úřední psaní (RR) ; Doporučený balíček (BA) |
    end

    class InformSenderAboutDelivery < Base
      @code = '38'
      @abbreviation = 'PID'
      @description = 'Předání informací z dodání'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) |
    end

    # class DepositWithoutDelivering < Base
    #   @code = '39'
    #   @abbreviation = 'PID'
    #   @description = 'Nedoručovat-uložit' }
    #   # ; Doporučená zásilka (RR) ; Úřední psaní (RR) |
    # end

    class DeliverToCompany < Base
      @code = '40'
      @abbreviation = 'DF'
      @description = 'Doručit firmě'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Nadrozměr (BN) ; Balík Expres (BE) |
    end

    # class ShipmentHandover < Base
    #   @code = '40'
    #   @abbreviation = ''
    #   @description = 'Předání zásilek (OJ, RJ)'
    # end

    class DocumentlessCashOnDelivery < Base
      @code = '41'
      @abbreviation = 'E'
      @description = 'Bezdokladová dobírka'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Do balíkovny (NB) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class Document < Base
      @code = '42'
      @abbreviation = 'DE'
      @description = 'Dokument (pouze pro zásilky do zahraničí)'
      # ; MZ EMS (EM) |
    end

    # class DeliveryAtSpecifiedWorkday < Base
    #   @code = '42'
    #   @abbreviation = ''
    #   @description = 'Roznos v 1 den'
    #   # ; RIPM | Roznáška informačních/propagačních materiálů (RIPM)
    # end

    class GiftOrNonCommercialGoods < Base
      @code = '43'
      @abbreviation = 'PE'
      @description = 'Zboží/Dárek (pouze pro zásilky do zahraničí)'
      # ; MZ Doporučené zásilky (RR) ; MZ Cenné psaní (VL) ; MZ EMS (EM) ; MZ Standardní balík (CS) ; MZ Cenný balík (CV) |
    end

    class ResponseEnvelope < Base
      @code = '43'
      @abbreviation = 'OL'
      @description = 'Odpovědní obálka'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Expres (BE) |
    end

    # class BundledByPostCode < Base
    #   @code = '43'
    #   @abbreviation = 'OL'
    #   @description = 'Svazkování s PSČ'
    #   # ; Obchodní psaní
    # end

    class GoodsWithExportDocumentsProcessed < Base
      @code = '44'
      @abbreviation = 'ZD'
      @description = 'MZ – Zboží s VDD (vývozní doprovodný doklad – pro uplatnění odpočtu DPH)'
      # ; MZ Doporučené zásilky (RR) ; MZ Cenné psaní (VL) ; MZ EMS (EM) ; MZ Standardní balík (CS) ; MZ Cenný balík (CV) ; Obchodní balík do zahraničí (CE) |
    end

    # class CertificateOfDeliveryWithReturnToSender < Base
    #   @code = '44'
    #   @abbreviation = ''
    #   @description = 'Dodejka-vrácení operátorovi (RJ)'
    #   # RJ => Zapsaná lisovní zásilka
    # end

    #  class BundledWithoutPostCode < Base
    #   @code = '45'
    #   @abbreviation = 'OL'
    #   @description = 'Svazkování bez PSČ'
    #   # ; Obchodní psaní
    # end

    class ThisSideUp < Base
      @code = '47'
      @abbreviation = 'NK'
      @description = 'Neklopit'
      # ; Balík Do ruky (DR, DV) nad 30 Kg ; Balík Nadrozměr (BN) |
    end

    # # I give up the naming!!!
    # class SubmissionWithPapers < Base
    #   @code = '47'
    #   @abbreviation = ''
    #   @description = 'Papírové podání (RJ)'

    # end

    # class DeliverToPoBoxZone4 < Base
    #   @code = '48'
    #   @abbreviation = ''
    #   @description = 'Zóna IV.P.O.BOX (OJ, RJ)'
    #   # Pokud je požadováno dodání zásilek do P.O.Boxu, který je na podací poště je nutné mít v souboru uvedenou službu 48
    # end

    class SaveKey < Base
      @code = '48'
      @abbreviation = 'SK'
      @description = 'Save Key'
    end

    class AddreseeVerification < Base
      @code = '49'
      @abbreviation = 'OU'
      @description = 'Ověření údajů'
      # (služba již zahrnuje služby 8 a 30) ; Balík Na poštu (NP, NV, NA)
    end

    # class DeliverToPoBox < Base
    #   @code = '49'
    #   @abbreviation = ''
    #   @description = 'P.O.BOX (OJ, RJ)'
    #   # Pokud je požadováno dodání zásilek do P.O.Boxu, který je na podací poště je nutné mít v souboru uvedenou službu 49
    # end

    class ReturnToSenderAfterXDays < Base
      @code = '4A'
      @abbreviation = ''
      @description = 'Vrátit odesílateli po uplynutí počtu dnů'
    end

    class ReturnToSenderImmediately < Base
      @code = '4B'
      @abbreviation = ''
      @description = 'Okamžitě vrátit odesílateli'
    end

    class DoNotReturnToSender < Base
      @code = '4C'
      @abbreviation = ''
      @description = 'Nevracet'
    end

    class ResendToOtherAddress < Base
      @code = '4D'
      @abbreviation = ''
      @description = 'Doslat na níže uvedenou adresu'
    end

    class RegisteredMail < Base
      @code = '50'
      @abbreviation = ''
      @description = 'Doporučená zásilka'
    end

    class RegisteredMailStandard < Base
      @code = '51'
      @abbreviation = ''
      @description = 'Doporučená zásilka standard'
    end

    class RegisteredMailForBlinds < Base
      @code = '52'
      @abbreviation = ''
      @description = 'Doporučená slepecká zásilka'
    end

    class InternationalRegisteredMail < Base
      @code = '53'
      @abbreviation = ''
      @description = 'Doporučená zásilka do zahraničí'
    end

    class InternationalRegisteredMailForBlinds < Base
      @code = '54'
      @abbreviation = ''
      @description = 'Doporučená slepecká zásilka do zahraničí'
    end

    class InternationalRegisteredPrintedMatterBag < Base
      @code = '55'
      @abbreviation = ''
      @description = 'Doporučený tiskovinový pytel do zahraničí'
    end

    class Missive < Base
      @code = '56'
      @abbreviation = ''
      @description = 'Úřední psaní'
    end

    class MissiveStandard < Base
      @code = '57'
      @abbreviation = ''
      @description = 'Úřední psaní standard'
    end

    # class InternationalRegisteredAerogram < Base
    #   @code = '58'
    #   @abbreviation = ''
    #   @description = 'Doporučený aerogram do zahraničí'
    # end

    # MYSTERIOUS_2 =                                                  { code: '59', abbreviation: '', name_cs:' }

    class CompanyRegisteredMail < Base
      @code = '60'
      @abbreviation = ''
      @description = 'Firemní psaní doporučeně'
    end

    class InternationalMail < Base
      @code = '61'
      @abbreviation = ''
      @description = 'Obyčejná zásilka do zahraničí'
    end

    class InternationalPrintedMatterBag < Base
      @code = '62'
      @abbreviation = ''
      @description = 'Obyčejný tiskovinový pytel do zahraničí'
    end

    class InternationalMailForBlinds < Base
      @code = '63'
      @abbreviation = ''
      @description = 'Obyčejná slepecká zásilka do zahraničí'
    end

    # MYSTERIOUS                                                     64 - 67

    class OnPalette < Base
      @code = '68'
      @abbreviation = 'PT'
      @description = 'Paleta'
      # ; Balík Nadrozměr (BN) |
    end

    class MultiParcelShippmentBig < Base
      @code = '69'
      @abbreviation = 'VII'
      @description = 'Vícekusová zásilka II'
      # ; Balík Nadrozměr (BN) |
    end

    class MultiParcelShippment < Base
      @code = '70'
      @abbreviation = 'VK'
      @description = 'Vícekusová zásilka'
      # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) |
    end

    class Consignment < Base
      @code = '71'
      @abbreviation = 'CG'
      @description = 'Consignment'
      # ; Doporučené zásilky (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    # MYSTERIOUS_10 =                                               { code: '72', abbreviation: '' }
    # MYSTERIOUS_11 =                                               { code: '73', abbreviation: '' }

    # class Stickerman < Base
    #   @code = '74'
    #   @abbreviation = ''
    #   @description = 'Polepovač'
    #   # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Cenný balík (B, BD, BB, V, VD, VV) |
    # end

    # class OrderMeditatedAtPostOffice < Base
    #   @code = '75'
    #   @abbreviation = ''
    #   @description = 'Zprostředkování objednávky'
    #   # ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) |
    # end

    # Notify sender
    class EAlertOfDeliverySms < Base
      @code = '76'
      @abbreviation = 'DM'
      @description = 'eDodejka SMS'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Komplet (BP) ; EMS (EE) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class EAlertOfDeliveryEmail < Base
      @code = '77'
      @abbreviation = 'DE'
      @description = 'eDodejka E-mail'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Komplet (BP) ; EMS (EE) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class EAlertOfDeliverySmsAndEmail < Base
      @code = '78'
      @abbreviation = 'eD'
      @description = 'eDodejka SMS + E-mail'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Komplet (BP) ; EMS (EE) ; Balík Expres (BE) ; Balík Nadrozměr (BN) ; Cenný balík (B, BD, BB, V, VD, VV) |
    end

    class SubmissionByPostbox < Base
      @code = '80'
      @abbreviation = 'PB'
      @description = 'Podání PostBox'
      # ; Doporučené zásilky (RR) ; Doporučená zásilka standard (RR) ; Úřední psaní (RR) |
    end

    # class Postbox < Base
    #   @code = '85'
    #   @abbreviation = ''
    #   @description = 'PostBox'
    #   # ; Balík Do ruky (DR, DV, DE) |
    # end

    class PreprocessedBySorting < Base
      @code = '91'
      @abbreviation = 'PP'
      @description = 'Předzpracovaná'
      # ; Doporučené zásilky (RR) ; Úřední psaní (RR) ; Doporučený balíček (BA) ; Cenné psaní (VL) ; Balík Do ruky (DR, DV, DE) ; Balík Na poštu (NP, NV, NA) ; Balík Komplet (BP) ; EMS (EE) ; Cenný balík (B, BD, BB, V, VD, VV)
    end

    class ReturnByAir < Base
      @code = '9A'
      @abbreviation = ''
      @description = 'Vrátit letecky'
    end

    class ReturnEconomically < Base
      @code = '9B'
      @abbreviation = ''
      @description = 'Vrátit ekonomicky'
    end

    class DiscountForOnlinePosting < Base
      @code = '97'
      @abbreviation = ''
      @description = 'Sleva za elektronické předání dat'
    end

    # **Pozn. U RR zásilek je vždy jedna ze služeb 50 až 60 povinná!!!!!!**
    # Čísla požadovaných služeb budou zadána do pole požadované služby k zásilce dle výše uvedeného číselníku v libovolném pořadí. Kombinace více služeb bude zadávána tímto způsobem, např. Dodejka, Pilně a Dobírka s Pk A: 3+4+15
    # U služeb pro elektronické avízo lze zadat vždy jen jednu z uvedených služeb 34 nebo 45 nebo 46. Kombinace těchto služeb není možná a bude na poště vyhodnocená jako chybná. Bez uvedení kontaktních údajů na adresáta (mobilní telefonní číslo nebo e-mail) není služba možná a na poště bude vyhodnocena jako chybná.
    # U služeb pro eDodejku lze zadat vždy jen jednu z uvedených služeb 76 nebo 77 nebo 78. Kombinace těchto služeb není možná a bude na poště vyhodnocená jako chybná. Bez uvedení kontaktních údajů na odesílatele (mobilní telefonní číslo nebo e-mail) není služba možná a na poště bude vyhodnocena jako chybná.
    # V případě Vícekusové zásilky se služba 69 a 70 zadává u každé zásilky, která je součástí vícekusové zásilky s tím, že navíc musí být povinně vyplněna pole č. 22 – ID hlavní zásilky (jedná se o zásilku první v pořadí), 23 – pořadové číslo zásilky ve VK a 24 – celkový počet zásilek ve VK. Tato pole jsou vyplněna u všech vět se službou 69 a 70.
    # V případě služby 69 – Vícekusová zásilka II je vždy současně povinná služba 16 – Neprodlužovat úložní dobu (služba 16 se uvádí u hlavní zásilky a současně také u vedlejších vícekusových zásilek). Služba 69 je určena pouze pro zásilku Balík Nadrozměr.
    # U služby 27 – Vyzvednutí zásilky třetí osobou je pro předání dat od podavatele povinné vyplnit pole č.26 – variabilní symbol zásilky (soubor K, N a M). Pokud nebude toto pole vyplněno, nebude tato dispozice uplatněna.
    # U služby 68 – Paleta je povinné vyplnění pole č. 35 (soubor M). Služba 68 – Paleta se zadává k hlavní zásilce i k vedlejším zásilkám.
    # U zásilek Balík Do ruky a Balík Nadrozměr je možné zadat službu 24-Komplexní doručení. Ke službě 24-Komplexní doručení je možné zadat službu 25-Odvoz starého spotřebiče. Službu 25 nelze zadat samostatně, tj. lze ji zadat pouze v kombinaci se sl.č.24.
    # V případě podání vícekusové zásilky Balík Do ruky nebo Balík Nadrozměr se službou 24, musí být služba 24 uvedena u všech zásilek vícekusu, tj. u hlavní i vedlejší zásilky.
    # V případě podání zásilky Balík Do ruky se službou 24-Komplexní doručení, musí být povinně vyplněno pole „Telefon adresáta“, do kterého je možné zadat telefonní číslo pevné linky nebo mobilního operátora v ČR. Pokud byla současně se službou 24 zadána služba 34-SMS avízo nebo 45-SMS+e-mail avízo, lze do pole „Telefon adresáta“ vyplnit pouze telefonní číslo mobilního operátora v ČR!!!!.
    # V případě podání zásilky Balík Nadrozměr se službou 24-Komplexní doručení, nesmí fyzická hmotnost zásilky přesáhnout 100kg (součet fyzických hmotností jednotlivých zásilek vícekusu nesmí přesáhnout 1000kg).
    # U zásilek se službou 36-Potvrzení dokumentace při dodání musí být povinně vyplněny údaje o adresátovi dokumentů, počet dokumentů určených k podpisu, e-mail odesílatele zásilky, e-mail nebo mobilní telefon adresáta zásilky.
    # U zásilek se sl. 75 – Zprostředkování objednávky je povinné vyplnění pole č. 61 Číslo objednávky (soubor P).
    # U zásilek se sl. 44 – Zboží s VVD je povinné vyplnění pole č. 31 MRN kód (soubor N, M, P)
    # U zásilek Balík Do ruky je možné uvést sl. 91 – Předzpracovaná. Službu podavatel u zásilek Balík Do ruky uvede v tom případě, že provede fyzické třídění zásilek na pásmo A (je požadováno doručení běžnou doručovací pochůzkou) a pásmo B (je požadováno doručení odpolední doručovací pochůzkou). Označení zásilek pásmem doručení A nebo B, viz Příloha č. 5.
    # V případě služeb 1A, 1B je nutné alfabetický znak v příslušné službě uvádět vždy velkými písmeny.
    # Podavatelé, kteří nemají sjednánu smluvní cenu, musí od 1. 3.2019 při podání zásilek Balík Do ruky, Balík Na poštu, Cenný Balík, Doporučený balíček, Balík Expres, Obyčejný balík a EMS uvádět povinně ve službách jednu z rozměrových služeb S, M, L, XL.

    # has to be at the end, to load all subcasses before
    def self.all_classes
      base_class = CzechPostB2bClient::PostServices::Base
      ObjectSpace.each_object(base_class.singleton_class).reject { |c| c == base_class }
    end
  end
end

# rubocop:enable Layout/LineLength
