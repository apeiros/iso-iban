# encoding: utf-8

require 'stringio'
require 'yaml'
require 'test/unit/assertions'
require 'fileutils'

module Kernel
  module_function
  def reset_test_files
    data_dir = "#{TEST_DIR}/data"
    tmp_dir  = "#{TEST_DIR}/tmp"
    FileUtils.rm_r(tmp_dir) if File.directory?(tmp_dir)
    FileUtils.cp_r(data_dir, tmp_dir)
  end

  def test_file(name)
    "#{TEST_DIR}/tmp/#{name}"
  end
end


module TestSuite
  attr_accessor :name
end

module Kernel
  def suite(name, &block)
    klass = Class.new(Test::Unit::TestCase)
    klass.extend TestSuite
    klass.name = "Suite #{name}"
    klass.class_eval(&block)

    klass
  end
  module_function :suite
end

class Test::Unit::TestCase
  def self.inherited(by)
    by.init
    super
  end

  def self.init
    @setups = []
  end

  def self.setup(&block)
    @setups ||= []
    @setups << block
  end

  class << self
    attr_reader :setups
  end

  def setup
    self.class.setups.each do |setup|
      instance_eval(&setup)
    end
    super
  end

  def self.suite(name, &block)
    klass = Class.new(Test::Unit::TestCase)
    klass.extend TestSuite
    klass.name = "#{self.name} #{name}"
    klass.class_eval(&block)

    klass
  end

  def self.test(desc, &impl)
    define_method("test #{desc}", &impl)
  end

  def capture_stdout
    captured  = StringIO.new
    $stdout   = captured
    yield
    captured.string
  ensure
    $stdout = STDOUT
  end
end
