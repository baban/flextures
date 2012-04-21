# encoding: utf-8

require 'flextures/flextures_base_config'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures'
require 'flextures/flextures_factory'
require 'flextures/flextures_loader'
require 'flextures/flextures_dumper'
require 'flextures/flextures_command'
require 'flextures/flextures_railtie' if defined? Rails
require 'flextures/rspec_flextures_support' if defined? RSpec
require 'flextures/testunit_flextures_support' if defined? Test::Unit::TestCase

