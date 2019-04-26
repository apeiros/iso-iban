# encoding: utf-8

require 'iso/iban'

# TODO: I can't make these tests fail - so I don't trust them
suite "spec config" do
  # using example data from France Spec: https://www.ecbs.org/iban/france-bank-account-number.html
  test 'ISO::IBAN FR - bank Branch' do
    assert ISO::IBAN.valid?('FR17 2004 1010 0505 0001 3M02 606')
    assert ISO::IBAN.valid?('FR14 2004 1010 0505 0001 3M02 606')
    assert_equal 'FR1420041010050500013M02606', ISO::IBAN.parse('FR14 2004 1010 0505 0001 3M02 606').compact
    assert_equal 20041, ISO::IBAN.new('FR1420041010050500013M02606').bank_code
    assert_equal 01005, ISO::IBAN.new('FR1420041010050500013M02606').branch_code
  end

end

# In my own project I used rpsec and these verify the FR spec change works
# # IBAN test nummern von: https://www.ecbs.org/iban.htm
# describe ".clearing nr (bank code) extrahieren von IBAN" do
#   # https://www.ecbs.org/iban/switzerland-bank-account-number.html
#   it "für CH - keine branche definiert im CH IBAN" do
#     expect( described_class.clearing('CH9300762011623852957') ).to eq '00762'
#   end
#   #  https://www.ecbs.org/iban/italy-bank-account-number.html
#   it "für IT - ohne Branch identifier: 11101" do
#     expect( described_class.clearing('IT60X0542811101000000123456') ).to eq '05428'
#   end
#   #  https://www.ecbs.org/iban/italy-bank-account-number.html
#   it "für IT - ohne Branch identifier: 11101" do
#     expect( described_class.clearing('IT60X0542811101000000123456', true) ).to eq '0542811101'
#   end
#   # https://www.ecbs.org/iban/germany-bank-account-number.html
#   it "für DE - keine Branche definiert im DE IBAN" do
#     expect( described_class.clearing('DE89370400440532013000') ).to eq '37040044'
#   end
#   # https://www.ecbs.org/iban/france-bank-account-number.html
#   it "für FR - ohne Branch identifier: 01005" do
#     expect( described_class.clearing('FR1420041010050500013M02606') ).to eq '20041'
#   end
#   # https://www.ecbs.org/iban/france-bank-account-number.html
#   it "für FR - mit Branch identifier: 01005" do
#     expect( described_class.clearing('FR1420041010050500013M02606', true) ).to eq '2004101005'
#   end
#   # https://www.ecbs.org/iban/france-bank-account-number.html
#   it "für ungueltige Eingaben - raise error" do
#     expect{ described_class.clearing('XX1420041010050500013M02606') }.to raise_error(Util::IbanError, 'Die Clearing-Nr. wurde nicht gefunden')
#   end
# end
