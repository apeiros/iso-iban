README
======


Summary
-------
ISO::IBAN implements IBAN (International Bank Account Number) specification as per ISO 13616-1.
It provides methods to generate valid IBAN numbers from components, or to validate a given IBAN.


Installation
------------
`gem install iso-iban`


Usage
-----

    ISO::IBAN.valid?('CH35 1234 5987 6543 2109 A')     # => true
    ISO::IBAN.validate('CH37 1234 5987 6543 2109 A')   # => [:invalid_checksum]
    ISO::IBAN.generate('CH', '12345', '987')           # => #<ISO::IBAN CH76 1234 5000 0000 0098 7>
    iban = ISO::IBAN.new('CH35 1234 5987 6543 2109 A') # => #<ISO::IBAN CH35 1234 5987 6543 2109 A>
    iban.formatted       # => "CH35 1234 5987 6543 2109 A"
    iban.compact         # => "CH351234598765432109A"
    iban.country         # => "CH"
    iban.checksum_digits # => "35"
    iban.bank_code       # => "12345"
    iban.account_code    # => "98765432109A"
    iban.valid?          # => true
    iban.validate        # => []

Links
-----

* [Online API Documentation](http://rdoc.info/github/apeiros/iso-iban/)
* [Public Repository](https://github.com/apeiros/iso-iban)
* [Bug Reporting](https://github.com/apeiros/iso-iban/issues)
* [RubyGems Site](https://rubygems.org/gems/iso-iban)


License
-------

You can use this code under the {file:LICENSE.txt BSD-2-Clause License}, free of charge.
If you need a different license, please ask the author.