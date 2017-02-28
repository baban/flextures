require "flextures/flextures_base_config"
require "flextures/flextures_factory"

module Flextures
  # guessing ActiveRecord Model name by table_name and create
  # @params [String|Symbol] table_name
  # @params [ActiveRecord::Base] model class
  def self.create_model(table_name)
    # when Model is defined in FactoryFilter
    a = -> do
      f = Factory::FACTORIES[table_name.to_sym]
      f && f[:model]
    end
    # when program can guess Model name by table_name
    b = -> do
      begin
        table_name.singularize.camelize.constantize
      rescue => e
        nil
      end
    end
    # when cannot guess Model name
    c = -> do
      Class.new(ActiveRecord::Base){ |o| o.table_name=table_name }
    end
    a.call || b.call || c.call
  end

  # load configuration file, if file is exist
  def self.load_configurations
    if defined?(Rails) and Rails.root
      [
        File.join(Rails.root.to_path, "/config/flextures.factory.rb"),
      ].each { |fn| File.exist?(fn) && load(fn) }
    end
  end

  # @return [Array] flextures useable table names
  def self.deletable_tables
    tables = ActiveRecord::Base.connection.data_sources
    Flextures::Configuration.ignore_tables.each { |name| tables.delete(name.to_s) }
    tables
  end

  # initialize table data
  def self.init_tables
    tables = Flextures::deletable_tables
    tables.each do |name|
      # if 'name' variable is 'database view', raise error
      begin
        Class.new(ActiveRecord::Base){ |o| o.table_name= name }.delete_all
      rescue => e
      end
    end
  end

  def self.delete_tables(*tables)
    tables.each do |name|
      # if 'name' variable is 'database view', raise error
      begin
        Class.new(ActiveRecord::Base){ |o| o.table_name= name }.delete_all
      rescue StandaraError => e
      end
    end
  end

  # It is debug method to use like 'tab' method
  # @params [Proc] dumper write dump information
  def self.table_tap(&dumper)
    tables = Flextures::deletable_tables
    tables.each do |name|
      # if 'name' variable is 'database view', raise error
      begin
        klass = Class.new(ActiveRecord::Base){ |o| o.table_name= name; }
        dumper.call klass
      rescue StandaraError => e
      end
    end
  end

  # parse arguments functions.
  module ARGS
    # parse rake ENV parameters
    def self.parse(env={}, option={})
      table_names = []
      if v = (env["T"] or env["TABLE"])
        table_names = v.split(',').map{ |name| { table: name, file: name } }
      end
      if v = (env["M"] or env["MODEL"])
        table_names = v.split(',').map do |name|
          name = name.constantize.table_name
          { table: name, file: name }
        end
      end

      table_names = Flextures::deletable_tables.map{ |name| { table: name, file: name } } if table_names.empty?

      # parse env["FIXTURES"] parameter
      fixtures_args_parser = ->(s){
        names = s.split(',')
        if env["TABLE"] or env["T"] or env["MODEL"] or env["M"]
          [ table_names.first.merge(file: names.first) ]
        else
          names.map{ |name| { table: name, file: name } }
        end
      }
      # parse filename and define parameters.
      table_names = fixtures_args_parser.call(env["FIXTURES"]) if env["FIXTURES"]
      table_names = fixtures_args_parser.call(env["FILE"])     if env["FILE"]
      table_names = fixtures_args_parser.call(env["F"])        if env["F"]

      table_names = table_names.map{ |option| option.merge(dir: env["DIR"]) } if env["DIR"]
      table_names = table_names.map{ |option| option.merge(dir: env["D"])   } if env["D"]

      table_names = table_names.map{ |option| option.merge(minus: env["MINUS"].to_s.split(",")) } if env["MINUS"]
      table_names = table_names.map{ |option| option.merge(plus:  env["PLUS"].to_s.split(","))  } if env["PLUS"]

      table_names = table_names.map{ |option| option.merge(silent: true) }   if env["OPTION"].to_s.split(",").include?("silent")
      table_names = table_names.map{ |option| option.merge(unfilter: true) } if env["OPTION"].to_s.split(",").include?("unfilter")
      table_names = table_names.map{ |option| option.merge(strict: true) }   if env["OPTION"].to_s.split(",").include?("strict")
      table_names = table_names.map{ |option| option.merge(stair: true) }    if env["OPTION"].to_s.split(",").include?("stair")

      # if mode is 'read mode' and file is not exist, value is not return.
      table_names.select!(&exist) if option[:mode] && option[:mode] == 'read'
      table_names
    end

    # check exist filename block
    def self.exist
      return ->(name) {
        File.exist?(File.join(Flextures::Configuration.load_directory, "#{name}.csv")) or
        File.exist?(File.join(Flextures::Configuration.load_directory, "#{name}.yml"))
      }
    end
  end
end
