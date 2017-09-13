# encoding: utf-8

Gem::Specification.new do |s|
  s.name                      = "iso-iban"
  s.version                   = "0.1.4"
  s.authors                   = "Stefan Rusterholz"
  s.email                     = "stefan.rusterholz@gmail.com"
  s.homepage                  = "https://github.com/apeiros/iso-iban"
  s.license                   = 'BSD 2-Clause'

  s.description               = <<-DESCRIPTION.gsub(/^    /, '').chomp
    ISO::IBAN implements IBAN (International Bank Account Number) specification as per ISO 13616-1.
    It provides methods to generate valid IBAN numbers from components, or to validate a given IBAN.
  DESCRIPTION
  s.summary                   = <<-SUMMARY.gsub(/^    /, '').chomp
    Utilities for International Bank Account Numbers (IBAN) as per ISO 13616-1.
  SUMMARY

  s.post_install_message      = <<-POST_INSTALL_MESSAGE.gsub(/^    /, '').chomp
    IMPORTANT!

    As of 0.1.0, there are 2 backward incompatible changes:

    * `require 'iso/iban/autoload'` is deprecated. Please use plain `require 'iso/iban'`.
      To load ISO::IBAN without loading the specifications, please use
      `require 'iso/iban/no_autoload'`.
    * ISO::IBAN.new no longer accepts formatted input.
      Use ISO::IBAN.parse if your input is potentially not in the compact format.
  POST_INSTALL_MESSAGE

  s.files                     =
    Dir['bin/**/*'] +
    Dir['data/**/*'] +
    Dir['documentation/**/*'] +
    Dir['lib/**/*'] +
    Dir['rake/**/*'] +
    Dir['test/**/*'] +
    Dir['*.gemspec'] +
    %w[
      .yardopts
      LICENSE.txt
      Rakefile
      README.markdown
    ]

  if File.directory?('bin') then
    s.executables = Dir.chdir('bin') { Dir.glob('**/*').select { |f| File.executable?(f) } }
  end

  s.required_ruby_version     = ">= 1.9.2"
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1")
  s.rubygems_version          = "1.3.1"
  s.specification_version     = 3
end
