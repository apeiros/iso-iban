ERRORS IN IBAN_Registry.txt
===========================

* AE, United Arab Emirates: Invalid iban_structure ('AE07 0331 2345 6789 0123 456', should be AE2!n3!n16!n)
* BH, Bahrain (Kingdom of): Invalid bban_length (22, should be 18)
* CR, Costa Rica: Invalid bban_length (7, should be 17)
* DE, Germany: Invalid bban_structure ('8!n10!n; ', should be 8!n10!n - i.e., contains a superfluous '; ')
* FI, Finland: Fields BBAN Structure, BBAN Length ("Not in use" - this seems wrong on all accounts - if the IBAN is not in use it should not be in the list, or should be noticed separately)
* HU, Hungary: Invalid bban_structure (':3!n4!n1!n15!n1!n:', should be 3!n4!n1!n15!n1!n - i.e., contains a superfluous ':')
* KW, Kuwait: Invalid iban_structure (KW2!n4!a22!, should be KW2!n4!a22!c)
* KZ, Kazakhstan: Inconsistent iban_structure (2!a2!n3!n13!c, should be KZ2!n3!n13!c)
* KZ, Kazakhstan: Invalid iban_length (empty, should be 20)
* LI, Liechtenstein (Principality of): Invalid bban_length (19, should be 17)
* MD, Republic of Moldova: Inconsistent iban_structure and bban_structure - in IBAN, bban part is 20!c, but BBAN states 2!c18!c, I suspect IBAN structure should be MD2!n2!c18!c instead of MD2!n20!c
* PL, Poland: Inconsistent iban_structure and bban_structure - in IBAN, bban part is 8!n16n, but BBAN states 8!n16!n, I suspect IBAN structure should be PL2!n8!n16!n instead of PL2!n8!n16n
* MR, Mauritania: Invalid iban_structure (MR135!n5!n11!n2!n, should be MR2!n5!n5!n11!n2!n)
* TN, Tunisia: Invalid iban_structure (TN592!n3!n13!n2!n, should be TN2!n2!n3!n13!n2!n)
* Various countries which aggregate the IBAN for multiple country codes
* Inconsistencies in the position specification (various countries)
