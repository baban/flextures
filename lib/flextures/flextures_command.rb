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
      def self.dump
        Flextures::init_load
        table_names = Flextures::ARGS.parse
        puts "dumping..."
        if ["yml","yaml"].include? ENV["FORMAT"]
          table_names.each { |fmt| Flextures::Dumper::yml(fmt) }
        else
          table_names.each { |fmt| Flextures::Dumper::csv(fmt) }
        end
      end

      def self.csvdump
        Flextures::init_load
        table_names = Flextures::ARGS.parse mode:'read'
        table_names.each { |fmt| Flextures::Dumper::csv(fmt) }
      end

      def self.ymldump
        Flextures::init_load
        table_names = Flextures::ARGS.parse mode:'read'
        table_names.each { |fmt| Flextures::Dumper::yml(fmt) }
      end

      def self.load
        table_names = Flextures::ARGS.parse
        Flextures::init_load
        Flextures::init_tables
        puts "loading..."
        table_names.map { |fmt| Flextures::Loader::load(fmt) }
      end

      def self.csvload
        table_names = Flextures::ARGS.parse
        Flextures::init_load
        Flextures::init_tables
        puts "loading..."
        table_names.map { |fmt| Flextures::Loader::csv(fmt) }
      end

      def self.ymlload
        table_names = Flextures::ARGS::parse
        Flextures::init_load
        Flextures::init_tables
        puts "loading..."
        table_names.map { |fmt| Flextures::Loader::yml(fmt) }
      end
    end
  end
end

