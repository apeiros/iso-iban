# encoding: utf-8

module ISO
  class IBAN

    # Specification of the IBAN format for one country. Every country has its
    # own specification of the IBAN format.
    # SWIFT is the official authority where those formats are registered.
    class Specification

      # A mapping from SWIFT structure specification to PCRE regex.
      StructureCodes = {
        'n' => '\d',
        'a' => '[A-Z]',
        'c' => '[A-Za-z0-9]',
        'e' => ' ',
      }

      # Load the specifications YAML.
      #
      # @return [Hash<String => ISO::IBAN::Specification>]
      def self.load_yaml(path)
        Hash[YAML.load_file(path).map { |country, spec| [country, new(*spec)] }]
      end

      # Parse the SWIFT provided file (which sadly is a huge mess and not machine friendly at all).
      #
      # @return [Array<ISO::IBAN::Specification>] an array with all specifications.
      def self.parse_file(path)
        File.read(path, encoding: Encoding::Windows_1252).encode(Encoding::UTF_8).split("\r\n").tap(&:shift).flat_map { |line|
          country_name, country_codes, iban_structure_raw, iban_length, bban_structure, bban_length, bank_position = line.split(/\t/).values_at(0,1,11,12,4,5,6)
          codes        = country_codes.size == 2 ? [country_codes] : country_codes.scan(/\b[A-Z]{2}\b/)
          primary_code = codes.first
          bank_position_from, bank_position_to, branch_position_from, branch_position_to = bank_position.match(/(?:[Pp]ositions?|) (\d+)-(\d+)(?:.*Branch identifier positions?: (\d+)-(\d+))?/).captures.map { |pos| pos && pos.to_i+3 }

          codes.map { |a2_country_code|
            iban_structure = iban_structure_raw[/#{a2_country_code}[acen\!\d]*/] || iban_structure_raw[/#{primary_code}[acen\!\d]*/]
            bban_structure = bban_structure[/[acen\!\d]*/]

            new(
              country_name.strip,
              a2_country_code,
              iban_structure,
              iban_length.to_i,
              bban_structure.strip,
              bban_length.to_i,
              bank_position_from,
              bank_position_to,
              branch_position_from,
              branch_position_to
            )
          }
        }
      end

      # *n:   Digits (numeric characters 0 to 9 only)
      # *a:   Upper case letters (alphabetic characters A-Z only)
      # *c:   upper and lower case alphanumeric characters (A-Z, a-z and 0-9)
      # *e:   blank space
      # *nn!: fixed length
      # *nn:  maximum length
      #
      # Example: "AL2!n8!n16!c"
      def self.structure_regex(structure, anchored=true, grouped = false)
        left_char = right_char = ''
        if grouped
          left_char = '('
          right_char = ')'
        end
        source = structure.scan(/([A-Z]+)|(\d+)(!?)([nac])/).map { |exact, length, fixed, code|
          if exact
            left_char + Regexp.escape(exact) + right_char
          else
            left_char + StructureCodes[code]+(fixed ? "{#{length}}" : "{,#{length}}") + right_char
          end
        }.join('')

        anchored ? /\A#{source}\z/ : /#{source}/
      end

      attr_reader :country_name,
                  :a2_country_code,
                  :iban_structure,
                  :iban_length,
                  :bban_structure,
                  :bban_length,
                  :bank_position_from,
                  :bank_position_to,
                  :branch_position_from,
                  :branch_position_to

      def initialize(country_name, a2_country_code, iban_structure, iban_length, bban_structure, bban_length, bank_position_from, bank_position_to, branch_position_from, branch_position_to)
        @country_name         = country_name
        @a2_country_code      = a2_country_code
        @iban_structure       = iban_structure
        @iban_length          = iban_length
        @bban_structure       = bban_structure
        @bban_length          = bban_length
        @bank_position_from   = bank_position_from
        @bank_position_to     = bank_position_to
        @branch_position_from = branch_position_from
        @branch_position_to   = branch_position_to
      end

      # @param [Boolean] grouped
      #   If true will build a regex with every component grouped. (ie. (IT)(\d{2})([A-Z]{1}))... )
      #
      # @return [Regexp] A regex to verify the structure of the IBAN. If grouped = true resulting regex will have components grouped.
      def iban_regex(grouped = false)
        @iban_regex ||= self.class.structure_regex(@iban_structure, true, grouped)
      end

      # @param [Boolean] grouped
      #   If true will build a regex with every component grouped. (ie. (IT)(\d{2})([A-Z]{1}))... )
      #
      # @return [Regexp] A regex to identify the structure of the IBAN, without anchors. If grouped = true resulting regex will have components grouped.
      def unanchored_iban_regex(grouped = false)
        self.class.structure_regex(@iban_structure, false, grouped)
      end

      # @param [Boolean] grouped
      #   If true resulting regex will have components grouped
      #
      # @return [Regexp] A regex to verify the structure of the IBAN.
      def iban_regex(grouped = false)
        @iban_regex ||= self.class.structure_regex(@iban_structure, true, grouped)
      end

      # @param [Boolean] grouped
      #   If true resulting regex will have components grouped
      #
      # @return [Regexp] A regex to identify the structure of the IBAN, without anchors.
      def unanchored_iban_regex(grouped = false)
        self.class.structure_regex(@iban_structure, false, grouped)
      end

      # @return [Array<Integer>] An array with the lengths of all components.
      def component_lengths
        [bank_code_length, branch_code_length, account_code_lenght].tap { |lengths| lengths.delete(0) }
      end

      # @return [Fixnum]
      #   The length of the bank code in the IBAN, 0 if the IBAN has no bank code.
      def bank_code_length
        @bank_position_from && @bank_position_to ? @bank_position_to-@bank_position_from+1 : 0
      end

      # @return [Fixnum]
      #   The length of the bank code in the IBAN, 0 if the IBAN has no branch code.
      def branch_code_length
        @branch_position_from && @branch_position_to ? @branch_position_to-@branch_position_from+1 : 0
      end

      # @return [Fixnum]
      #   The length of the account code in the IBAN.
      def account_code_lenght
        bban_length-bank_code_length-branch_code_length
      end

      # @return [Array] An array with the Specification properties. Used for serialization.
      def to_a
        [
          @country_name,
          @a2_country_code,
          @iban_structure,
          @iban_length,
          @bban_structure,
          @bban_length,
          @bank_position_from,
          @bank_position_to,
          @branch_position_from,
          @branch_position_to,
        ]
      end
    end
  end
end
