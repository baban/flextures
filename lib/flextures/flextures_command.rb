# encoding: utf-8

require 'ostruct'
require 'csv'

require 'flextures/flextures_base_config'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures'
require 'flextures/flextures_factory'

module Flextures
  module Rake
    module Command
      def dump
        table_names = Flextures::ARGS.parse
        Flextures::init_load
        puts "dumping..."
        if ["yml","yaml"].include? ENV["FORMAT"]
          table_names.each { |fmt| Flextures::Dumper::yml(fmt) }
        else
          table_names.each { |fmt| Flextures::Dumper::csv(fmt) }
        end
      end

      def csvdump
        table_names = Flextures::ARGS.parse
        Flextures::init_load
        table_names.each { |fmt| Flextures::Dumper::csv(fmt) }
      end

      def ymldump
        table_names = Flextures::ARGS.parse
        Flextures::init_load
        table_names.each { |fmt| Flextures::Dumper::yml(fmt) }
      end

      def load
        table_names = Flextures::ARGS.parse
        Flextures::init_load
        Flextures::init_tables
        puts "loading..."
        table_names.each { |fmt| Flextures::Loader::load(fmt) }
      end

      def csvload
        table_names = Flextures::ARGS.parse
        Flextures::init_load
        Flextures::init_tables
        table_names.each { |fmt| Flextures::Loader::csv(fmt) }
      end

      def ymlload
        table_names = Flextures::ARGS::parse
        Flextures::init_load
        Flextures::init_tables
        table_names.each { |fmt| Flextures::Loader::yml(fmt) }
      end
    end
  end
end

