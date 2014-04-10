# run with `ruby test/runner.rb`
# if you only want to run a single test-file: `ruby test/runner.rb testfile.rb`

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH << File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../test/lib', __FILE__)
TEST_DIR    = File.expand_path('../../test', __FILE__)

require 'test/unit'
require 'helper'

units = (ARGV.empty? || ENV['RAKE']) ? Dir["#{TEST_DIR}/unit/**/*.rb"] : ARGV

units.each do |unit|
  puts unit
  load unit
end
