# encoding: utf-8

require 'ostruct'
require 'csv'

require 'flextures/flextures_base_config'
require 'flextures/flextures'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures_factory'

namespace :db do
  namespace :flextures do
    desc "Dump data to csv format"
    task :dump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    desc "Dump data to prefer csv format"
    task :csvdump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    desc "Dump data to yaml format"
    task :ymldump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::yml(fmt) }
    end

    desc "load fixture data csv format"
    task :load => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Loader::load(fmt) }
    end

    desc "load fixture data only csv format files"
    task :csvload => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Loader::csv(fmt) }
    end

    desc "load fixture files only yaml format"
    task :ymlload => :environment do
      Flextures::ARGS::parse.each { |fmt| Flextures::Loader::yml(fmt) }
    end
  end
end
