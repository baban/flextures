# encoding: utf-8

require 'ostruct'
require 'csv'

require 'flextures/flextures_base_config'
require 'flextures/flextures'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures_factory'
#require 'flextures/rspec_flextures_support'

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
