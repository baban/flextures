require 'active_record'

require 'flextures/version'
require 'flextures/flextures_base_config'
require 'flextures/flextures'
require 'flextures/flextures_factory'
require 'flextures/flextures_loader'
require 'flextures/flextures_dumper'
require 'flextures/flextures_command'
require 'flextures/flextures_railtie' if defined? Rails
require 'flextures/rspec_flextures_support' if defined? RSpec
