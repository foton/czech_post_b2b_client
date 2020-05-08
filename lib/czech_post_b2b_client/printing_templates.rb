# frozen_string_literal: true

# Available printing templates, which can be used in AdressSheetsGenerator `options[:template_id]`
#
# Do not miss `CzechPostB2bClient::PrintingTemplates.all_classes` method,
# it has to be at end of module to work properly
module CzechPostB2bClient
  module PrintingTemplates
    class Base
      class << self
        attr_reader :id, :description
      end
    end

    module AdressLabel
      class Simple < Base
        @id = 7
        @description = 'adresní štítek (alonž) - samostatný'
      end

      class SimpleWithCODVoucherA < Base
        @id = 8
        @description = 'adresní štítek (alonž) + dobírková poukázka A'
      end
      class Blank4OnPage < Base
        @id = 20
        @description = 'adresní štítek bianco - 4x (A4)'
      end

      class Blank < Base
        @id = 21
        @description = 'adresní štítek bianco - samostatný'
      end

      class BlankLandscape < Base
        @id = 39
        @description = 'adresní štítek bianco - samostatný (na šířku)'
      end

      module ForeignPackage
        class Standard < Base
          @id = 58
          @description = 'AŠ - samostatný Standardní balík do zahraničí'
        end

        class Standard4OnPage < Base
          @id = 59
          @description = 'AŠ - 4xA4 Standardní balík do zahraničí'
        end

        class Valuable < Base
          @id = 60
          @description = 'AŠ - samostatný Cenný balík do zahraničí'
        end

        class Valuable4OnPage < Base
          @id = 61
          @description = '4xA4 Cenný balík do zahraničí'
        end

        class EMS < Base
          @id = 62
          @description = 'AŠ - samostatný EMS zahraničí'
        end

        class EMS2x4 < Base
          @id = 63
          @description = 'AŠ - 2xA4 EMS do zahraničí'
        end
      end
    end

    module Envelope
      class EnvelopeC6 < Base
        @id = 22
        @description = 'obálka 1 - C6'
      end

      class EnvelopeC5 < Base
        @id = 23
        @description = 'obálka 2 - C5'
      end

      class EnvelopeB4 < Base
        @id = 24
        @description = 'obálka 3 - B4'
      end

      class EnvelopeDL < Base
        @id = 25
        @description = 'obálka 4 - DL bez okénka'
      end
    end

    class CODVoucherA < Base
      @id = 10
      @description = 'poštovní dobírková poukázka A - samostatná'
    end

    class CODVoucherA3OnPage < Base
      @id = 11
      @description = 'poštovní dobírková poukázka A - 3x (A4)'
    end

    class CODVoucherC < Base
      @id = 12
      @description = 'Poštovní dobírková poukázka C'
    end

    class CODVoucherForCSOB < Base
      @id = 13
      @description = 'Dobírková složenka ČSOB'
    end

    class RRLabels3x8 < Base
      @id = 26
      @description = 'štítky pro RR - 3x8 (A4)'
    end

    class IntegratedDocument < Base
      @id = 38
      @description = 'Integrovaný doklad'
    end

    class AddressData3x8 < Base
      @id = 40
      @description = 'Adresní údaje 3x8 (A4)'
    end

    class DeliveryTicket < Base
      @id = 41
      @description = 'Dodejka'
    end

    class CustomDeclarationCN22 < Base
      @id = 56
      @description = 'Celní prohlášení CN22'
    end

    class CustomDeclarationCN23 < Base
      @id = 57
      @description = 'Celní prohlášení CN23'
    end

    # Formulare ID 72 a 73 je mozno pouzit pouze pro zasilky s prefixem CE
    # do zemi AT, DE, FR, GR, HR, CH, IS, LU, LV, NO, PL, SK
    class HarmonizedLabel < Base
      @id = 72
      @description = 'Harmonizovaný štítek pro MZ produkty – samostatný'
    end

    class HarmonizedLabel4OnPage < Base
      @id = 73
      @description = 'Harmonizovaný štítek pro MZ produkty –  4x (A4)'
    end

    # has to be at the end, to load all subcasses before
    def all_classes
      ObjectSpace.each_object(CzechPostB2bClient::PrintingTemplates::Base.singleton_class)
    end
    module_function :all_classes
  end
end
