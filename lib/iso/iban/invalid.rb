# encoding: utf-8

module ISO
  class IBAN

    # Raised by ISO::IBAN::parse!
    class Invalid < ArgumentError

      # @return [Array<Symbol>] The errors in the IBAN.
      # @see ISO::IBAN#validate
      attr_reader :errors

      # @return [ISO::IBAN] The faulty IBAN.
      attr_reader :iban

      def initialize(iban)
        super("The IBAN #{iban.formatted} is invalid (#{@errors.join(', ')})")
        @iban   = iban
        @errors = iban.validate
      end
    end
  end
end
