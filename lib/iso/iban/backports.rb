# encoding: utf-8

# Port some newer ruby methods back
unless String.method_defined?(:b)

  # Backports from ruby 2.0 used in ISO::IBAN
  class String

    # @example
    #     str.b   -> str
    #
    # Returns a copied string whose encoding is ASCII-8BIT.
    def b
      dup.force_encoding(Encoding::BINARY)
    end
  end
end
