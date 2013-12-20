# encoding: utf-8

require 'iso/iban'

suite "ISO::IBAN" do
  setup do
    ISO::IBAN.instance_variable_set(:@specifications, {'CH' => ISO::IBAN::Specification.new("Switzerland", "CH", "CH2!n5!n12!c", 21, "5!n12!c", 17, 4, 8, nil, nil)})
  end

  # since the specs provided by swift are a mess, we do a sanity check
  test 'Specifications provided by SWIFT' do
    ISO::IBAN.load_specifications
    ISO::IBAN.specifications.each do |country, spec|
      structure_length = spec.iban_structure.scan(/([A-Z]+)|(\d+)(!?)([nac])/).map { |exact, length, fixed, code|
        exact ? exact.length : length.to_i
      }.inject(:+)

      assert_equal spec.iban_length, structure_length, "Spec for country #{country} is invalid, invalid length"
      assert_equal spec.bban_structure, spec.iban_structure[5..-1], "Spec for country #{country} is invalid, iban differs from country + 2!n + bban"
      assert_equal spec.bban_length, spec.iban_length-4, "Spec for country #{country} is invalid, iban length differs from bban length + 4"
    end
  end

  test 'Random IBAN generation' do
    ISO::IBAN.load_specifications
    ISO::IBAN.specifications.each do |country, spec|
      assert ISO::IBAN.random(country).valid?, "Random IBAN generator for country #{country} is invalid"
    end
  end

  test 'ISO::IBAN::generate problem, TODO (this test is expected to fail at the moment)' do
    ISO::IBAN.instance_variable_set(:@specifications, {'BG' => ISO::IBAN::Specification.new("Bulgaria", "BG", "BG2!n4!a4!n2!n8!c", 22, "4!a4!n2!n8!c", 18, 4, 7, 8, 11)})
    assert ISO::IBAN.generate('BG', 'AAAA', '2', 'C').valid? # this works now
    assert ISO::IBAN.generate('BG', 'A', '2', 'C').valid? # this still fails, because ISO::IBAN::generate can't pad 'a' format fields
  end

  test 'ISO::IBAN::load_specifications' do
    reset_test_files

    ISO::IBAN.load_specifications(test_file('test_spec.yaml'))
    specs = ISO::IBAN.specifications
    assert_kind_of Hash, specs
    specs.each do |key, value|
      assert_kind_of String, key
      assert_kind_of ISO::IBAN::Specification, value
      assert_equal key, value.a2_country_code
    end
    assert_equal ["AL", "AD"], specs.keys
  end

  test 'ISO::IBAN::numerify' do
    assert_equal 121735123459876543210910, ISO::IBAN.numerify('CH351234598765432109A')
    assert_raise ArgumentError do
      ISO::IBAN.numerify('CH99 1234 5987 6543 2109 A')
    end
  end

  test 'ISO::IBAN::generate' do
    assert_equal 'CH76 0012 3000 0000 9876 B', ISO::IBAN.generate('CH', '123', '9876B').formatted
  end

  test 'ISO::IBAN::valid?' do
    assert ISO::IBAN.valid?('CH35 1234 5987 6543 2109 A')
    assert !ISO::IBAN.valid?('CH99 1234 5987 6543 2109 A')
    assert !ISO::IBAN.valid?('foo')
  end

  test 'ISO::IBAN::validate' do
    assert_equal [], ISO::IBAN.validate('CH35 1234 5987 6543 2109 A')
    assert_equal [:invalid_checksum], ISO::IBAN.validate('CH99 1234 5987 6543 2109 A')
    assert_equal [:invalid_format], ISO::IBAN.validate('CH86 X234 5987 6543 2109 A')
    assert_equal [:invalid_checksum, :invalid_format], ISO::IBAN.validate('CH99 X234 5987 6543 2109 A')
    assert_equal [:invalid_length, :invalid_format], ISO::IBAN.validate('CH83 X234 5987 6543 2109 AB')
    assert_equal [:invalid_checksum, :invalid_length, :invalid_format], ISO::IBAN.validate('CH99 X234 5987 6543 2109 AB')
    assert_equal [:invalid_country, :invalid_checksum, :invalid_length, :invalid_format], ISO::IBAN.validate('XX35 1234 5987 6543 2109 A')
  end

  test "ISO::IBAN::new" do
    assert_kind_of ISO::IBAN, ISO::IBAN.new('CH35 1234 5987 6543 2109 A')
    assert_kind_of ISO::IBAN, ISO::IBAN.new('CH351234598765432109A')
  end

  test "ISO::IBAN#formatted" do
    assert_equal 'CH35 1234 5987 6543 2109 A', ISO::IBAN.new('CH35 1234 5987 6543 2109 A').formatted
    assert_equal 'CH35 1234 5987 6543 2109 A', ISO::IBAN.new('CH351234598765432109A').formatted
  end

  test "ISO::IBAN#compact" do
    assert_equal 'CH351234598765432109A', ISO::IBAN.new('CH35 1234 5987 6543 2109 A').compact
    assert_equal 'CH351234598765432109A', ISO::IBAN.new('CH351234598765432109A').compact
  end

  test "ISO::IBAN#to_s" do
    assert_equal 'CH351234598765432109A', ISO::IBAN.new('CH35 1234 5987 6543 2109 A').to_s
    assert_equal 'CH351234598765432109A', ISO::IBAN.new('CH351234598765432109A').to_s
  end

  test "ISO::IBAN#country" do
    assert_equal 'CH', ISO::IBAN.new('CH35 1234 5987 6543 2109 A').country
  end

  test "ISO::IBAN#checksum_digits" do
    assert_equal '35', ISO::IBAN.new('CH35 1234 5987 6543 2109 A').checksum_digits
  end

  test "ISO::IBAN#bban" do
    assert_equal '1234598765432109A', ISO::IBAN.new('CH35 1234 5987 6543 2109 A').bban
  end

  test "ISO::IBAN#bank_code" do
    assert_equal '12345', ISO::IBAN.new('CH35 1234 5987 6543 2109 A').bank_code
  end

  test "ISO::IBAN#branch_code" do
    ISO::IBAN.instance_variable_set(:@specifications, {'BG' => ISO::IBAN::Specification.new("Bulgaria", "BG", "BG2!n4!a4!n2!n8!c", 22, "4!a4!n2!n8!c", 18, 4, 7, 8, 11)})
    assert_equal "0002", ISO::IBAN.new('BG69 0001 0002 0300 0000 04').branch_code
  end

  test "ISO::IBAN#account_code" do
    assert_equal '98765432109A', ISO::IBAN.new('CH35 1234 5987 6543 2109 A').account_code
  end

  test "ISO::IBAN#valid?" do
    assert_equal true,  ISO::IBAN.new('CH35 1234 5987 6543 2109 A').valid?
    assert_equal false, ISO::IBAN.new('CH99 1234 5987 6543 2109 A').valid?
  end

  test "ISO::IBAN#validate" do
    assert_equal [], ISO::IBAN.new('CH35 1234 5987 6543 2109 A').validate
  end

  test "ISO::IBAN#<=>" do
    iban0 = ISO::IBAN.generate('CH', '0', '0')
    iban1 = ISO::IBAN.generate('CH', '0', '97') # 97 to have the same checksum
    assert_equal  -1, iban0 <=> iban1
    assert_equal   0, iban0 <=> iban0
    assert_equal   1, iban1 <=> iban0
    assert_equal nil, iban0 <=> "incomparable"
    assert_equal nil, "incomparable" <=> iban0
  end

  test "ISO::IBAN#inspect" do
    assert_equal "#<ISO::IBAN CH35 1234 5987 6543 2109 A>", ISO::IBAN.new('CH35 1234 5987 6543 2109 A').inspect
  end
end
