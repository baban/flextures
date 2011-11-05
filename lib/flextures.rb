# encoding: utf-8

require 'ostruct'
require 'csv'

# 基本設定
require 'flextures/flextures_base_config'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures_factory'
require 'flextures/rspec_flextures_support'
require 'flextures/flextures_railtie' if defined? Rails

# 上書き設定ファイルの読み出し
#load "#{Rails.root.to_path}/config/flextures.config.rb" if defined? Rails
# factory設定
#load "#{Rails.root.to_path}/config/flextures.factory.rb" if defined? Rails
