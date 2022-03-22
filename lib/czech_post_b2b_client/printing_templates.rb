# frozen_string_literal: true

# Available printing templates, which can be used in AdressSheetsGenerator `options[:template_id]`
#
# Do not miss `CzechPostB2bClient::PrintingTemplates.all_classes` method,
# it has to be at end of module to work properly
module CzechPostB2bClient
  module PrintingTemplates
    class Base
      class << self
        attr_reader :id, :description, :page_dimensions
      end
    end

    module AddressLabel
      class Simple < Base
        @id = 7
        @description = 'adresní štítek (alonž) [1x1/4 A4'
        @page_dimensions = 'A4 portrait (210 × 297 mm)'
      end

      class SimpleA6FourOnPage < Base
        @id = 103
        @description = 'Adresní štítek A6 : 4x'
        @page_dimensions = 'A4 portrait (210 × 297 mm)'
      end

      class SimpleWithCODVoucherA < Base
        @id = 8
        @description = 'adresní štítek (alonž) + dobírková poukázka A [(1x1/4 A4 + 1x1/2 A4)'
        @page_dimensions = 'A4 portrait (210 × 297 mm)'
      end

      class BiancoFourOnPage < Base
        @id = 20
        @description = 'adresní štítek bianco : 4x'
        @page_dimensions = 'A4 landscape (297 × 210 mm)'
      end

      class Bianco < Base
        @id = 21
        @description = 'adresní štítek bianco'
        @page_dimensions = 'A6 portrait (105 × 148 mm)'
      end

      class BiancoLandscape < Base
        @id = 39
        @description = 'adresní štítek bianco - na šířku'
        @page_dimensions = 'A6 landscape (148 × 105 mm)'
      end

      module ForeignPackage
        class Standard < Base
          @id = 58
          @description = 'CP72 - standardní balík do zahraničí' # or 'AŠ - samostatný Standardní balík do zahraničí'
          @page_dimensions = 'A5 landscape (210 × 148 mm)'
        end

        class StandardTwoOnPage < Base
          @id = 59
          @description = 'CP72 - standardní balík do zahraničí : 2x' # or 'AŠ - 4xA4 Standardní balík do zahraničí'
          @page_dimensions = 'A4 portrait (297 × 210 mm)'
        end

        class Insured < Base
          @id = 60
          @description = 'CP72 - cenný balík do zahraničí' # or 'AŠ - samostatný Cenný balík do zahraničí'
          @page_dimensions = 'A5 landscape (210 × 148 mm)'
        end

        class InsuredFourOnPage < Base
          @id = 61
          @description = 'CP72 - cenný balík do zahraničí : 2x' # or '4xA4 Cenný balík do zahraničí'
          @page_dimensions = 'A4 portrait (297 × 210 mm)'
        end

        class EMS < Base
          @id = 62
          @description = 'AŠ - samostatný EMS zahraničí'
          @page_dimensions = 'unverified'
        end

        class EMSTwoOnPage < Base
          @id = 63
          @description = 'AŠ - EMS do zahraničí : 2x'
          @page_dimensions = 'unverified A4'
        end
      end
    end

    module Envelope
      class EnvelopeC6 < Base
        @id = 22
        @description = 'obálka 1 - C6'
        @page_dimensions = 'C6 portrait (114 × 162 mm)'
      end

      class EnvelopeC5 < Base
        @id = 23
        @description = 'obálka 2 - C5'
        @page_dimensions = 'C5/prc7 portrait (162 × 229 mm)'
      end

      class EnvelopeB4 < Base
        @id = 24
        @description = 'obálka 3 - B4'
        @page_dimensions = 'B4 portrait (250 × 353 mm)'
      end

      class EnvelopeDL < Base
        @id = 25
        @description = 'obálka 4 - DL bez okénka'
        @page_dimensions = 'DL/prc5 portrait (109 × 219 mm)'
      end
    end

    class CODVoucherA < Base
      @id = 10
      @description = 'poštovní dobírková poukázka A - samostatná'
      @page_dimensions = '102 × 210 mm'
    end

    class CODVoucherAThreeOnPage < Base
      @id = 11
      @description = 'poštovní dobírková poukázka A - 3x'
      @page_dimensions = '210 × 306 mm'
    end

    class CODVoucherC < Base
      @id = 12
      @description = 'Poštovní dobírková poukázka C'
      @page_dimensions = 'unverified'
    end

    class CODVoucherForCSOB < Base
      @id = 13
      @description = 'Dobírková složenka ČSOB'
      @page_dimensions = 'unverified'
    end

    class RRLabels3x8 < Base
      @id = 26
      @description = 'štítky pro RR : 3x8'
      @page_dimensions = 'A4 portrait (210 × 297 mm)'
    end

    class IntegratedDocument < Base
      @id = 38
      @description = 'Integrovaný doklad'
      @page_dimensions = 'unverified'
    end

    class AddressData3x8 < Base
      @id = 40
      @description = 'Adresní údaje : 3x8'
      @page_dimensions = 'A4 portrait (210 × 297 mm)'
    end

    class DeliveryTicket < Base
      @id = 41
      @description = 'Dodejka'
      @page_dimensions = 'unverified'
    end

    module CustomsDeclaration
      class CN22 < Base
        @id = 56
        @description = 'Celní prohlášení CN22 [samotný tisk je velikosti cca A6 vlevo nahořu od středu]'
        @page_dimensions = 'A4 portrait (210 × 297 mm)'
      end

      class CN23 < Base
        @id = 57
        @description = 'Celní prohlášení CN23'
        @page_dimensions = 'A5 landscape (210 × 148 mm)'
      end

      class CN22FourOnPage < Base
        @id = 74
        @description = 'Celní prohlášení CN22 : 4x (A4)'
        @page_dimensions = 'unverified A4'
      end

      class CN22WithCK < Base
        @id = 75
        @description = 'Celní prohlášení CN22 s ČK (A4)'
        @page_dimensions = 'unverified A4'
      end

      class CN22WithCKFourOnPage < Base
        @id = 76
        @description = 'Celní prohlášení CN22 s ČK : 4x (A4)'
        @page_dimensions = 'unverified A4'
      end
    end

    class CN22FourOnPage < Base
      @id = 74
      @description = 'Celní prohlášení CN22 : 4x'
      @page_dimensions = 'A4 portrait (210 × 297 mm)'
    end

    module HarmonizedLabel
      # Formulare ID 72 a 73 je mozno pouzit pouze pro zasilky s prefixem CE
      # do zemi AT, DE, FR, GR, HR, CH, IS, LU, LV, NO, PL, SK
      class Simple < Base
        @id = 72
        @description = 'Obchodní balík do zahraničí' # or 'Harmonizovaný štítek pro MZ produkty-samostatný'
        @page_dimensions = 'unverified'
      end

      class SimpleFourOnPage < Base
        @id = 73
        @description = 'Obchodní balík do zahraničí : 4x (A4)' # or 'Harmonizovaný štítek pro MZ produkty – 4x (A4)'
        @page_dimensions = 'unverified A4'
      end

      class BiancoFourOnPage < Base
        @id = 100
        @description = 'Harmonizovaný štítek bianco : 4x'
        @page_dimensions = 'A4 portrait (210 × 297 mm)'
      end

      class Bianco < Base
        @id = 101
        @description = 'Harmonizovaný štítek bianco'
        @page_dimensions = 'A6 portrait (105 × 148 mm)'
      end

      class BiancoPortrait < Base
        @id = 102
        @description = 'Harmonizovaný štítek bianco - na výšku'
        @page_dimensions = 'A6 landscape (148 × 105 mm)'
      end

      class ZebraBianco105x148 < Base
        @id = 200
        @description = 'Harmonizovaný štítek bianco - (Zebra - 105x148); nejde o PDF'
        @page_dimensions = 'unverified 105 × 148 mm'
      end

      class ZebraBianco100x150 < Base
        @id = 201
        @description = 'Harmonizovaný štítek bianco - (Zebra - 100x150); nejde o PDF'
        @page_dimensions = 'unverified 100 × 150 mm'
      end

      class ZebraBianco100x125 < Base
        @id = 202
        @description = 'Harmonizovaný štítek bianco - (Zebra - 100x125); nejde o PDF'
        @page_dimensions = 'unverified 100 × 125 mm'
      end
    end

    # has to be at the end, to load all subcasses before
    def self.all_classes
      base_class = CzechPostB2bClient::PrintingTemplates::Base
      ObjectSpace.each_object(base_class.singleton_class).reject { |c| c == base_class }
    end
  end
end
