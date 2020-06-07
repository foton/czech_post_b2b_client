# frozen_string_literal: true

# rubocop:disable Style/AsciiComments

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

    module AddressLabel
      class Simple < Base
        @id = 7
        @description = 'adresní štítek (alonž) - samostatný'
      end

      class SimpleA6FourOnPage < Base
        @id = 103
        @description = 'Adresní štítek A6 – 4x'
      end

      class SimpleWithCODVoucherA < Base
        @id = 8
        @description = 'adresní štítek (alonž) + dobírková poukázka A'
      end

      class BiancoFourOnPage < Base
        @id = 20
        @description = 'adresní štítek bianco - 4x (A4)'
      end

      class Bianco < Base
        @id = 21
        @description = 'adresní štítek bianco - samostatný'
      end

      class BiancoLandscape < Base
        @id = 39
        @description = 'adresní štítek bianco - samostatný (na šířku)'
      end

      module ForeignPackage
        class Standard < Base
          @id = 58
          @description = 'CP72 - standardní balík do zahraničí' # or 'AŠ - samostatný Standardní balík do zahraničí'
        end

        class StandardTwoOnPage < Base
          @id = 59
          @description = 'CP72 - standardní balík do zahraničí (2x A4 )' # or 'AŠ - 4xA4 Standardní balík do zahraničí'
        end

        class Insured < Base
          @id = 60
          @description = 'CP72 - cenný balík do zahraničí' # or 'AŠ - samostatný Cenný balík do zahraničí'
        end

        class InsuredFourOnPage < Base
          @id = 61
          @description = 'CP72 - cenný balík do zahraničí (2x A4)' # or '4xA4 Cenný balík do zahraničí'
        end

        class EMS < Base
          @id = 62
          @description = 'AŠ - samostatný EMS zahraničí'
        end

        class EMSTwoOnPage < Base
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

    class CODVoucherAThreeOnPage < Base
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

    module CustomsDeclaration
      class CN22 < Base
        @id = 56
        @description = 'Celní prohlášení CN22 - 1x (A4)'
      end

      class CN23 < Base
        @id = 57
        @description = 'Celní prohlášení CN23 - 1x (A4)'
      end

      class CN22FourOnPage < Base
        @id = 74
        @description = 'Celní prohlášení CN22 - 4x (A4)'
      end

      class CN22WithCK < Base
        @id = 75
        @description = 'Celní prohlášení CN22  s ČK - 1x (A4)'
      end

      class CN22WithCKFourOnPage < Base
        @id = 76
        @description = 'Celní prohlášení CN22  s ČK - 4x (A4)'
      end
    end

    class CN22FourOnPage < Base
      @id = 74
      @description = 'Celní prohlášení CN22 - 4x (A4)'
    end

    module HarmonizedLabel
      # Formulare ID 72 a 73 je mozno pouzit pouze pro zasilky s prefixem CE
      # do zemi AT, DE, FR, GR, HR, CH, IS, LU, LV, NO, PL, SK
      class Simple < Base
        @id = 72
        @description = 'Obchodní balík do zahraničí – samostatný' # or 'Harmonizovaný štítek pro MZ produkty-samostatný'
      end

      class SimpleFourOnPage < Base
        @id = 73
        @description = 'Obchodní balík do zahraničí –  4x (A4)' # or 'Harmonizovaný štítek pro MZ produkty – 4x (A4)'
      end

      class BiancoFourOnPage < Base
        @id = 100
        @description = 'Harmonizovaný štítek bianco – 4x (A4)'
      end

      class Bianco < Base
        @id = 101
        @description = 'Harmonizovaný štítek bianco – samostatný'
      end

      class BiancoPortrait < Base
        @id = 102
        @description = 'Harmonizovaný štítek bianco – samostatný (na výšku)'
      end

      class ZebraBianco105x148 < Base
        @id = 200
        @description = 'Harmonizovaný štítek bianco - (Zebra - 105x148)'
      end

      class ZebraBianco100x150 < Base
        @id = 201
        @description = 'Harmonizovaný štítek bianco - (Zebra - 100x150)'
      end

      class ZebraBianco100x125 < Base
        @id = 202
        @description = 'Harmonizovaný štítek bianco - (Zebra - 100x125)'
      end
    end

    # has to be at the end, to load all subcasses before
    def self.all_classes
      ObjectSpace.each_object(CzechPostB2bClient::PrintingTemplates::Base.singleton_class)
    end
  end
end

# rubocop:enable Style/AsciiComments
