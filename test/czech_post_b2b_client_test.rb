# frozen_string_literal: true

require 'test_helper'

class CzechPostB2bClientTest < Minitest::Test
  def test_it_has_a_version_number
    refute_nil ::CzechPostB2bClient::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_knows_available_templates
    all_templates = CzechPostB2bClient::PrintingTemplates.all_classes.to_a

    assert_equal 31, all_templates.size

    template_61 = all_templates.detect { |t| t.id == 61 }
    assert_equal 'CP72 - cenný balík do zahraničí (2x A4)', template_61.description
  end

  def test_knowns_available_services
    all_services = CzechPostB2bClient::PostServices.all_classes.to_a

    assert_equal 90, all_services.size

    service_32 = all_services.detect { |t| t.code == '32' }
    # assert service_32.# CertificateOfDeliveryWithDeliverToAdresseeOnly
    assert_equal 'DZ', service_32.abbreviation
    assert_equal 'Dodejka a do vlastních rukou', service_32.description
  end

  def test_knowns_response_codes
    all_codes = CzechPostB2bClient::ResponseCodes.all_classes.to_a

    assert_equal 263, all_codes.size

    code_396 = all_codes.detect { |t| t.code == 396 }
    assert_equal 'INFO_CANCEL_SERVICE_5C', code_396.text
    assert_equal 'Zrušena služba 5C - neuveden kontaktní údaj adresáta', code_396.description
    assert_equal :info, code_396.type
  end
end
