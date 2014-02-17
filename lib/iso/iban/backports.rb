# encoding: utf-8

# Port some newer ruby methods back
unless String.method_defined?(:b)
  class String
    def b
      dup.force_encoding(Encoding::BINARY)
    end
  end
end
