# encoding: utf-8

require 'flextures/flextures'

namespace :db do
  namespace :flextures do
    desc "Dump data to csv format"
    task :dump => :environment do
      table_names = Flextures::ARGS.parse
      Flextures::init_load
      table_names.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    desc "Dump data to prefer csv format"
    task :csvdump => :environment do
      table_names = Flextures::ARGS.parse
      Flextures::init_load
      table_names.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    desc "Dump data to yaml format"
    task :ymldump => :environment do
      table_names = Flextures::ARGS.parse
      Flextures::init_load
      table_names.each { |fmt| Flextures::Dumper::yml(fmt) }
    end

    desc "load fixture data csv format"
    task :load => :environment do
      table_names = Flextures::ARGS.parse
      Flextures::init_load
      Flextures::init_tables
      table_names.each { |fmt| Flextures::Loader::load(fmt) }
    end

    desc "load fixture data only csv format files"
    task :csvload => :environment do
      table_names = Flextures::ARGS.parse
      Flextures::init_load
      Flextures::init_tables
      table_names.each { |fmt| Flextures::Loader::csv(fmt) }
    end

    desc "load fixture files only yaml format"
    task :ymlload => :environment do
      table_names = Flextures::ARGS::parse
      Flextures::init_load
      Flextures::init_tables
      table_names.each { |fmt| Flextures::Loader::yml(fmt) }
    end
  end
end
