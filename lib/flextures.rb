# encoding: utf-8

require 'ostruct'
require 'csv'

# ��{�ݒ�
require 'flextures/flextures_base_config'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures_factory'
require 'flextures/rspec_flextures_support'
require 'flextures/flextures_railtie' if defined? Rails

# �㏑���ݒ�t�@�C���̓ǂݏo��
#load "#{Rails.root.to_path}/config/flextures.config.rb" if defined? Rails
# factory�ݒ�
#load "#{Rails.root.to_path}/config/flextures.factory.rb" if defined? Rails
