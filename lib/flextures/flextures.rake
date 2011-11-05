# encoding: utf-8

require 'ostruct'
require 'csv'

# 基本設定
require 'flextures/flextures_base_config'
require 'flextures/flextures'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures_factory'
#require 'flextures/rspec_flextures_support'
require 'flextures/flextures_railtie' if defined? Rails

# 上書き設定ファイルの読み出し
#load "#{Rails.root.to_path}/config/flextures.config.rb" if defined? Rails
# factory設定
#load "#{Rails.root.to_path}/config/flextures.factory.rb" if defined? Rails


namespace :db do
  namespace :flextures do
    desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :dump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :csvdump => :environment do
      #Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :ymldump => :environment do
      #Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::yml(fmt) }
    end

    desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :load => :environment do
      #Flextures::ARGS.parse.each { |fmt| Flextures::Loader::load(fmt) }
    end

    desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :csvload => :environment do
      #Flextures::ARGS.parse.each { |fmt| Flextures::Loader::csv(fmt) }
    end

    desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :ymlload => :environment do
      #Flextures::ARGS::parse.each { |fmt| Flextures::Loader::yml(fmt) }
    end
  end
end
