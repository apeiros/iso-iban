README
======


Summary
-------

ISO::IBAN implements the IBAN (International Bank Account Number) specification as per ISO 13616-1.
It provides methods to generate valid IBAN numbers from components, or to validate a given IBAN.


Installation
------------

### Via rubygems

    gem install iso-iban

### From github

    git clone https://github.com/apeiros/iso-iban.git
    cd iso-iban
    rm -r *.gem
    gem build *.gemspec
    gem install *.gem


Usage
-----

    require 'iso/iban'
    ISO::IBAN.valid?('CH35 1234 5987 6543 2109 A')       # => true
    ISO::IBAN.validate('CH37 1234 5987 6543 2109 A')     # => [:invalid_checksum]
    ISO::IBAN.generate('CH', '12345', '987')             # => #<ISO::IBAN CH76 1234 5000 0000 0098 7>
    iban = ISO::IBAN.parse('CH35 1234 5987 6543 2109 A') # => #<ISO::IBAN CH35 1234 5987 6543 2109 A>
    iban = ISO::IBAN.new('CH351234598765432109A')        # => #<ISO::IBAN CH35 1234 5987 6543 2109 A>
    iban.formatted       # => "CH35 1234 5987 6543 2109 A"
    iban.compact         # => "CH351234598765432109A"
    iban.country         # => "CH"
    iban.checksum_digits # => "35"
    iban.bank_code       # => "12345"
    iban.account_code    # => "98765432109A"
    iban.valid?          # => true
    iban.validate        # => []

**Note:** iso/iban automatically loads the IBAN specifications delivered with the gem. If you do not wish
those to be loaded, `require 'iso/iban/no_autoload'` instead.


ENV
---

ISO::IBAN.load_specifications (which is automatically called when you require 'iso/iban') uses the
ENV variable `IBAN_SPECIFICATIONS` to determine where to look for IBAN specifications. If that
variable is not set, it will default to the datafile delivered with the gem.


Links
-----

* [Online API Documentation](http://rdoc.info/github/apeiros/iso-iban/)
* [Public Repository](https://github.com/apeiros/iso-iban)
* [Bug Reporting](https://github.com/apeiros/iso-iban/issues)
* [RubyGems Site](https://rubygems.org/gems/iso-iban)


Contributors
------------

* Carsten Wirth (ISO::IBAN#parse accepts nil)
* John Cant (Travis CI)


License
-------

You can use this code under the {file:LICENSE.txt BSD-2-Clause License}, free of charge.
If you need a different license, please ask the author.
