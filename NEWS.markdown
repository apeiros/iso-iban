NEWS
====

0.1.3
-----

* Accept lower case IBANs and convert them to uppercase.
* ISO::IBAN::parse (and in consequence ::parse!, ::valid? and ::validate) accept nil as argument.
* Added section "Contributors" to README.
* Added NEWS.markdown.


0.1.2
-----

* Fix for bug which caused templated IBANs not to validate properly.


0.1.1
-----

* Fix for bug which caused ISO::IBAN::valid? and family to raise an exception on invalid characters.


0.1.0
-----

* First tagged release.
