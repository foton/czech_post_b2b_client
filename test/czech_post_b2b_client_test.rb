# frozen_string_literal: true

require 'test_helper'

class CzechPostB2bClientTest < Minitest::Test
  def test_it_has_a_version_number
    refute_nil ::CzechPostB2bClient::VERSION
  end

  def test_knows_available_templates
    all_templates = CzechPostB2bClient::PrintingTemplates.all_classes.to_a

    assert_equal 38, all_templates.size

    template_61 = all_templates.detect { |t| t.id == 61 }
    assert_equal 'CP72 - cenný balík do zahraničí : 2x', template_61.description
  end

  def test_knowns_available_services
    all_services = CzechPostB2bClient::PostServices.all_classes.to_a

    assert_equal 89, all_services.size

    service_32 = all_services.detect { |t| t.code == '32' }
    # assert service_32.# CertificateOfDeliveryWithDeliverToAdresseeOnly
    assert_equal 'DZ', service_32.abbreviation
    assert_equal 'Dodejka a do vlastních rukou', service_32.description
  end

  def test_knowns_all_response_codes
    assert_equal 276, CzechPostB2bClient::ResponseCodes.all_classes.to_a.size
  end

  def test_knows_info_respose_code
    code_396 = CzechPostB2bClient::ResponseCodes.new_by_code(396)
    assert_equal 'INFO_CANCEL_SERVICE_5C', code_396.text
    assert_equal 'Zrušena služba 5C - neuveden kontaktní údaj adresáta', code_396.description
    assert_equal :info, code_396.type
    assert_equal '', code_396.details
  end

  def test_knows_error_respose_code
    code_420 = CzechPostB2bClient::ResponseCodes.new_by_code(420, 'Chickens are not valid goods')
    assert_equal 'INVALID_CONTENT_CUSTOM_GOOD', code_420.text
    assert_equal 'Neplatný popis celního obsahu', code_420.description
    assert_equal :error, code_420.type
    assert_equal 'Chickens are not valid goods', code_420.details
  end
end
