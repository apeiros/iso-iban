# encoding: utf-8

begin
  require 'rubygems/version' # newer rubygems use this
rescue LoadError
  require 'gem/version' # older rubygems use this
end

module ISO
  class IBAN

    # The version of the sorting gem.
    # @note
    #   require 'iso/iban' loads the version.
    #
    Version = Gem::Version.new("0.0.4")
  end
end
