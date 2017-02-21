require 'ostruct'
require 'csv'

require 'flextures/flextures_base_config'
require 'flextures/flextures'
require 'flextures/flextures_factory'

module Flextures
  module Rake
    module Command
      def self.dump
        Flextures::load_configurations
        table_names = Flextures::ARGS.parse(ENV)
        puts "dumping..."
        case ENV["FORMAT"].to_s.to_sym
        when :yml,:yaml
          table_names.map { |fmt| Flextures::Dumper::yml(fmt) }
        when :csv
          table_names.map { |fmt| Flextures::Dumper::csv(fmt) }
        else
          table_names.map { |fmt| Flextures::Dumper::csv(fmt) }
        end
      end

      def self.load
        Flextures::load_configurations
        table_names = Flextures::ARGS.parse(ENV)
        Flextures::init_tables unless ENV["T"] or ENV["TABLE"] or ENV["M"] or ENV["MODEL"] or ENV["F"] or ENV["FIXTUES"]
        file_format = ENV["FORMAT"]
        puts "loading..."
        case file_format.to_s.to_sym
        when :csv
          table_names.map { |fmt| Flextures::Loader::load(fmt, %i[csv]) }
        when :yml
          table_names.map { |fmt| Flextures::Loader::load(fmt, %i[yml]) }
        else
          table_names.map { |fmt| Flextures::Loader::load(fmt) }
        end
      end

      # load and dump data
      def self.generate
        Flextures::load_configurations
        table_names = Flextures::ARGS.parse(ENV)
        Flextures::init_tables unless ENV["T"] or ENV["TABLE"] or ENV["M"] or ENV["MODEL"] or ENV["F"] or ENV["FIXTUES"]
        file_format = ENV["FORMAT"]
        puts "generating..."
        case file_format.to_s.to_sym
        when :yml
          table_names.map { |fmt| Flextures::Loader::yml(fmt); Flextures::Dumper::yml(fmt) }
        when :csv
          table_names.map { |fmt| Flextures::Loader::csv(fmt); Flextures::Dumper::csv(fmt) }
        else
          table_names.map { |fmt| Flextures::Loader::csv(fmt); Flextures::Dumper::csv(fmt) }
        end
      end
    end
  end
end
