# encoding: utf-8

require 'iso/iban/backports'
require 'iso/iban/invalid'
require 'iso/iban/specification'
require 'iso/iban/version'
require 'yaml'

# Container for classes which implement ISO standards.
module ISO

  # IBAN - ISO 13616-1
  #
  # Usage
  # =====
  #
  #     require 'iso/iban'
  #     ISO::IBAN.valid?('CH35 1234 5987 6543 2109 A')       # => true
  #     ISO::IBAN.validate('CH37 1234 5987 6543 2109 A')     # => [:invalid_checksum]
  #     ISO::IBAN.generate('CH', '12345', '987')             # => #<ISO::IBAN CH76 1234 5000 0000 0098 7>
  #     iban = ISO::IBAN.parse('CH35 1234 5987 6543 2109 A') # => #<ISO::IBAN CH35 1234 5987 6543 2109 A>
  #     iban = ISO::IBAN.new('CH351234598765432109A')        # => #<ISO::IBAN CH35 1234 5987 6543 2109 A>
  #     iban.formatted       # => "CH35 1234 5987 6543 2109 A"
  #     iban.compact         # => "CH351234598765432109A"
  #     iban.country         # => "CH"
  #     iban.checksum_digits # => "35"
  #     iban.bank_code       # => "12345"
  #     iban.account_code    # => "98765432109A"
  #     iban.valid?          # => true
  #     iban.validate        # => []
  #
  # General IBAN Information
  # ========================
  #
  # * **What is an IBAN?**  
  #   IBAN stands for International Bank Account Number. It is the ISO 13616
  #   international standard for numbering bank accounts. In 2006, the
  #   International Organization for Standardization (ISO) designated SWIFT as
  #   the Registration Authority for ISO 13616.
  #
  # * **Use**  
  #   The IBAN facilitates the communication and processing of cross-border
  #   transactions. It allows exchanging account identification details in a
  #   machine-readable form.
  #
  #
  # The ISO 13616 IBAN Standard
  # ===========================
  #
  # * **Structure**  
  #   The IBAN structure is defined in ISO 13616-1 and consists of a two-letter
  #   ISO 3166-1 country code, followed by two check digits and up to thirty
  #   alphanumeric characters for a BBAN (Basic Bank Account Number) which has a
  #   fixed length per country and, included within it, a bank identifier with a
  #   fixed position and a fixed length per country. The check digits are
  #   calculated based on the scheme defined in ISO/IEC 7064 (MOD97-10).
  #
  # * **Terms and definitions**  
  #     * *Bank identifier:* The identifier that uniquely identifies the financial
  #       institution and, when appropriate, the branch of that financial institution
  #       servicing an account.  
  #     * *BBAN:* basic bank account number: The identifier that uniquely identifies
  #       an individual account, at a specific financial institution, in a particular
  #       country. The BBAN includes a bank identifier of the financial institution
  #       servicing that account.  
  #     * *IBAN:* international bank account number: The expanded version of the
  #       basic bank account number (BBAN), intended for use internationally. The
  #       IBAN uniquely identifies an individual account, at a specific financial
  #       institution, in a particular country.
  #
  # * **Submitters**  
  #   Nationally-agreed, ISO13616-compliant IBAN formats are submitted to the
  #   registration authority exclusively by the National Standards Body or the
  #   National Central Bank of the country.
  class IBAN
    include Comparable

    # Character code translation used to convert an IBAN into its numeric
    # (digits-only) form
    CharacterCodes  = Hash[('0'..'9').zip('0'..'9')+('a'..'z').zip(10..35)+('A'..'Z').zip(10..35)]

    # All uppercase letters
    UpperAlpha   = [*'A'..'Z']

    # All lowercase letters
    LowerAlpha   = [*'a'..'z']

    # All digits
    Digits       = [*'0'..'9']

    # All uppercase letters, lowercase letters and digits
    AlphaNumeric = [*'A'..'Z', *'a'..'z', *'0'..'9']

    # All specifications, see ISO::IBAN::Specification
    @specifications = nil

    # @note
    #   Using `require 'iso/iban'` will automatically invoke this method.
    #   If you do not wish this behavior, `require 'iso/iban/no_autoload'` instead.
    #
    # Load the IBAN specifications file, which determines how the IBAN
    # for any given country looks.
    #
    # It will use the following sources in this order (first one which exists wins)
    #
    # * Path passed as `spec_file` parameter
    # * Path provided by the env variable `IBAN_SPECIFICATIONS`
    # * The file `../data/iso-iban/specs.yaml` relative to the lib dir
    # * The Gem datadir path
    #
    # @param [String] spec_file
    #   Override the default specifications file path.
    #
    # @return [self]
    def self.load_specifications(spec_file=nil)
      if spec_file then
        # do nothing
      elsif ENV['IBAN_SPECIFICATIONS'] then
        spec_file = ENV['IBAN_SPECIFICATIONS']
      else
        spec_file = File.expand_path('../../../../data/iso-iban/specs.yaml', __FILE__)
        if !File.file?(spec_file) && defined?(Gem) && Gem.datadir('iso-iban')
          spec_file = Gem.datadir('iso-iban')+'/specs.yaml'
        end
      end

      if spec_file && File.file?(spec_file)
        @specifications = ISO::IBAN::Specification.load_yaml(spec_file)
      elsif spec_file
        raise "Could not load IBAN specifications, specs file #{spec_file.inspect} does not exist or can't be read."
      else
        raise "Could not load IBAN specifications, no specs file found."
      end

      self
    end

    # @return [Hash<String => ISO::IBAN::Specification>]
    #   A hash with the country (ISO3166 2-letter) as key and the specification for that country as value.
    def self.specifications
      @specifications || raise("No specifications have been loaded yet - Check the docs for ISO::IBAN::load_specifications.")
    end

    # @param [String] a2_country_code
    #   The country (ISO3166 2-letter), e.g. 'CH' or 'DE'.
    #
    # @return [ISO::IBAN::Specification]
    #   The specification for the given country.
    def self.specification(a2_country_code, *default, &default_block)
      specifications.fetch(a2_country_code, *default, &default_block)
    end

    # @param [String] iban
    #   An IBAN number, either in compact or human format.
    #
    # @return [true, false]
    #   Whether the IBAN is valid.  
    #   See {#validate} for details.
    def self.valid?(iban)
      parse(iban).valid?
    end

    # @param [String] iban
    #   An IBAN number, either in compact or human format.
    #
    # @return [Array<Symbol>]
    #   An array with a code of all validation errors, empty if valid.  
    #   See {#validate} for details.
    def self.validate(iban)
      parse(iban).validate
    end

    # @param [String] iban
    #   The IBAN in either compact or human readable form.
    #
    # @return [String]
    #   The IBAN in compact form, all whitespace and dashes stripped.
    def self.strip(iban)
      iban.delete("\n\r\t -")
    end

    # Like ISO::IBAN.parse, but raises an ISO::IBAN::Invalid exception if the IBAN is invalid.
    #
    # @param [String, nil] iban_number
    #   The IBAN in either compact or human readable form.
    #
    # @return [ISO::IBAN]
    #   An IBAN instance representing the passed IBAN number.
    def self.parse!(iban_number)
      iban   = parse(iban_number)
      raise Invalid.new(iban) unless iban.valid?

      iban
    end

    # @param [String, nil] iban_number
    #   The IBAN in either compact or human readable form.
    #
    # @return [ISO::IBAN]
    #   An IBAN instance representing the passed IBAN number.
    def self.parse(iban_number)
      new(strip(iban_number || ""))
    end

    # Generate an IBAN from country code and components, automatically filling in the checksum.
    #
    # @note
    #   `generate` will pad all segments with zeros, which means it will generate invalid
    #   IBANs if you provide too short segments which are alphabetic only.  
    #   For example, `ISO::IBAN.generate('BG', 'A', '2', 'C')` generates an invalid IBAN.
    #
    # @example Generate an IBAN for UBS Switzerland with account number '12345'
    #     ISO::IBAN.generate('CH', '216', '12345') # => #<ISO::IBAN CH92 0021 6000 0000 1234 5>
    #
    # @param [String] country
    #   The ISO-3166 2-letter country code.
    #
    def self.generate(country, *components)
      spec      = specification(country)

      if spec.component_lengths.size != components.size
        raise ArgumentError, "#{spec.component_lengths.size} components expected but got #{components.size}."
      end

      justified = spec.component_lengths.zip(components).map { |length, component|
        if length != component.size
          raise ArgumentError, "Component '#{component}' is expected to be #{length} chars sized."
        end

        component.rjust(length, "0") 
      }
      iban      = new(country+'??'+justified.join(''))
      iban.update_checksum!

      iban
    end

    # @param [String] countries
    #   A list of 2 letter country codes. If empty, all countries in ISO::IBAN::specifications are used.
    #
    # @return [ISO::IBAN] A random, valid IBAN.
    def self.random(*countries)
      countries = specifications.keys if countries.empty?
      country   = countries.sample
      account   = specification(country).iban_structure.scan(/([A-Z]+)|(\d+)(!?)([nac])/).map { |exact, length, fixed, code|
        if exact
          exact
        elsif code == 'a'
          Array.new(length.to_i) { UpperAlpha.sample }.join('')
        elsif code == 'c'
          Array.new(length.to_i) { AlphaNumeric.sample }.join('')
        elsif code == 'e'
          ' '*length.to_i
        elsif code == 'n'
          Array.new(length.to_i) { Digits.sample }.join('')
        end
      }.join('')
      account[2,2] = '??'
      iban = new(account)
      iban.update_checksum!

      iban
    end

    # Converts a String into its digits-only form, i.e. all characters a-z are replaced with their corresponding
    # digit sequences, according to the IBAN specification.
    #
    # @param [String] string
    #   The string to convert into its numeric form.
    #
    # @return [String] The string in its numeric, digits-only form.
    def self.numerify(string)
      string.downcase.gsub(/\D/) { |char|
        CharacterCodes.fetch(char) {
          raise ArgumentError, "The string contains an invalid character #{char.inspect}"
        }
      }.to_i
    end

    # @return [String] The standard form of the IBAN for machine communication, without spaces, encoded in Encoding::BINARY.
    attr_reader :compact

    # @return [String] The ISO-3166 2-letter country code (first and second character).
    attr_reader :country

    # @return [ISO::IBAN::Specification] The specification for this IBAN (determined by its country).
    attr_reader :specification

    # @param [String] iban
    #   The IBAN number, must be in compact form. Use ISO::IBAN::parse for formatted IBANs.
    def initialize(iban)
      raise ArgumentError, "String expected for iban, but got #{iban.class}" unless iban.is_a?(String)

      @compact       = iban.b.upcase
      @country       = @compact[0,2]
      @specification = self.class.specification(@country, nil)
    end

    # @example Formatted IBAN
    #
    #     ISO::IBAN.new('CH')
    #
    # @return [String] The IBAN in its formatted form, which is more human readable than the compact form.
    def formatted
      @_formatted ||= @compact.gsub(/.{4}(?=.)/, '\0 ')
    end

    # @return [Integer, nil]
    #   IBAN in its numeric form, i.e. all characters a-z are replaced with their corresponding
    #   digit sequences.  
    #   Will return nil if the IBAN is shorter than 5 characters (which makes it invalid).
    def numeric
      @compact.size < 5 ? nil : self.class.numerify(@compact[4..-1]+@compact[0,4])
    end

    # @return [true, false]
    #   Whether the IBAN is valid.
    #   See {#validate} for details.
    def valid?
      valid_characters? && valid_country? && valid_checksum? && valid_length? && valid_format?
    end

    # @note
    #   The class method {ISO::IBAN.validate} uses {ISO::IBAN.parse}, which means it will strip whitespace and
    #   dashes from the IBAN.  
    #   {ISO::IBAN#initialize} on the other hand expects the IBAN in compact format and will not strip
    #   those characters.
    #
    # Error codes:
    #
    # * :invalid_characters
    # * :invalid_country
    # * :invalid_checksum
    # * :invalid_length
    # * :invalid_format
    #
    # Invalid characters means that the IBAN contains characters which are not in the set of A-Za-z0-9. See {#invalid_characters}.  
    # Invalid country means the country is unknown (character 1 & 2 in the IBAN).  
    # Invalid checksum means the two check digits (character 3 & 4 in the IBAN).  
    # Invalid length means the IBAN does not comply with the length specified for the country of that IBAN.  
    # Invalid format means the IBAN does not comply with the format specified for the country of that IBAN.  
    #
    # @return [Array<Symbol>] An array with a code of all validation errors, empty if valid.
    def validate
      errors   = []
      errors << :invalid_characters unless valid_characters?
      errors << :invalid_country    unless valid_country?
      errors << :invalid_checksum   unless valid_characters? && valid_checksum?
      errors << :invalid_length     unless valid_length?
      errors << :invalid_format     unless valid_format?

      errors
    end

    # @return [String] The checksum digits in the IBAN (character 3 & 4).
    def checksum_digits
      @compact[2,2]
    end

    # @return [String] The BBAN of the IBAN (everything except the country code and check digits).
    def bban
      @compact[4..-1]
    end

    # @return [String, nil] The bank code part of the IBAN, nil if not applicable.
    def bank_code
      if @specification && @specification.bank_position_from && @specification.bank_position_to
        @compact[@specification.bank_position_from..@specification.bank_position_to]
      else
        nil
      end
    end

    # @return [String, nil] The branch code part of the IBAN, nil if not applicable.
    def branch_code
      if @specification && @specification.branch_position_from && @specification.branch_position_to
        @compact[@specification.branch_position_from..@specification.branch_position_to]
      else
        nil
      end
    end

    # @return [String] The account code part of the IBAN.
    def account_code
      @compact[((@specification.branch_position_to || @specification.bank_position_to || 3)+1)..-1]
    end

    # @example
    #     invalid = "hägar"
    #     invalid.encoding # => #<Encoding:UTF-8>
    #     ISO::IBAN.new(invalid).invalid_characters          # => ["\xC3", "\xA4"]
    #     ISO::IBAN.new(invalid).invalid_characters('utf-8') # => ["ä"]
    #
    # @param [String, Encoding, nil] input_encoding
    #   ISO::IBAN::new interprets the passed IBAN as binary.
    #   If you got the IBAN from a source which is not binary, you should provide that encoding.
    #   Otherwise an invalid character may be split into multiple bytes.
    #
    # @return [Array] An Array with all invalid characters.
    def invalid_characters(input_encoding=nil)
      iban = input_encoding ? @compact.dup.force_encoding(input_encoding) : @compact

      iban.gsub(/[A-Z0-9?]*/i, '').chars.to_a.uniq # to_a is for ruby <= 2.0 where String#chars returns an Enumerator
    end

    # @return [true, false] Whether IBAN consists only of valid characters.
    def valid_characters?
      @compact =~ /\A[A-Z]{2}(?:\d\d|\?\?)[A-Z0-9]*\z/in ? true : false
    end

    # @return [true, false] Whether the country of the IBAN is valid.
    def valid_country?
      @specification ? true : false
    end

    # @return [true, false] Whether the format of the IBAN is valid.
    def valid_format?
      @specification && @specification.iban_regex =~ @compact ? true : false
    end

    # @return [true, false] Whether the length of the IBAN is valid.
    def valid_length?
      @specification && @compact.size == @specification.iban_length ? true : false
    end

    # @return [true, false] Whether the checksum of the IBAN is valid.
    def valid_checksum?
      numerified = numeric()

      numerified && (numerified % 97 == 1)
    end

    # See Object#<=>
    #
    # @return [-1, 0, 1, nil]
    def <=>(other)
      other.respond_to?(:compact) ? @compact <=> other.compact : nil
    end

    # Requires that the checksum digits were left as '??', replaces them with
    # the proper checksum.
    #
    # @return [self]
    def update_checksum!
      raise "Checksum digit placeholders missing" unless @compact[2,2] == '??'

      @compact[2,2] = calculated_check_digits
      @_formatted   = nil

      self
    end

    # @return [String] The check-digits as calculated from the IBAN.
    def calculated_check_digits
      "%02d" % (98-(self.class.numerify(bban+@country)*100)%97)
    end

    # @return [true, false]
    #   Whether two ISO::IBANs are equal.
    #   Comparison is based on class and IBAN number
    def eql?(other)
      self.class.equal?(other.class) && self == other
    end

    # @return [Integer]
    #   A hash value, see Object#hash
    def hash
      [self.class, @compact].hash
    end

    # See Object#inspect
    def inspect
      sprintf "#<%p %s>", self.class, formatted
    end

    # @return [String] The compact form of the IBAN as a String.
    def to_s
      @compact.dup
    end

    # @note
    #   This method is experimental. It might change or be removed in future versions!
    #
    # @return [Array]
    #   The individual IBAN components as defined by the SWIFT specification.
    #   An empty array if this IBAN does not have a specification.
    def to_a
      @_components ||= @specification ? @compact.match(@specification.iban_regex).captures : []

      @_components.dup
    end
  end
end
