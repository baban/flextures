# encoding: utf-8

require 'ostruct'
require 'csv'

# ��������
require 'flextures_base_config'
# �������ե�������ɤ߽Ф�
require "#{Rails.root.to_path}/config/flextures.config.rb" if File.exist? "#{Rails.root.to_path}/config/flextures.config.rb" 
require 'flextures'
require 'flextures_extension_modules'
require 'flextures_factory'
require 'rspec_flextures_support.rb'
# factory����
require "#{Rails.root.to_path}/config/flextures.factory.rb" if File.exist? "#{Rails.root.to_path}/config/flextures.factory.rb" 

