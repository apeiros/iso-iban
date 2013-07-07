$LOAD_PATH.unshift File.expand_path('lib')

desc 'Updates and generates the YAML file with the IBAN specs'
task :update_iban_specs => [:update_iban_registry, :generate_iban_specs]

desc 'Updates the dev/IBAN_Registry.txt file from the internet'
task :update_iban_registry do
  require 'open-uri'
  File.write('dev/IBAN_Registry.txt', open('http://www.swift.com/dsp/resources/documents/IBAN_Registry.txt', &:read))
end

desc 'Generates the YAML file with the IBAN specs from the local dev/IBAN_Registry.txt'
task :generate_iban_specs do
  require 'iso/iban/specification'
  require 'yaml'

  specs = ISO::IBAN::Specification.parse_file('dev/IBAN_Registry.txt')
  File.write('data/iso-iban/specs.yaml', Hash[specs.map { |spec| [spec.a2_country_code, spec.to_a] }].to_yaml)
end
