# encoding: utf-8

require 'ostruct'
require 'csv'

require "flextures/flextures_base_config"
require "flextures/flextures_extension_modules"
require "flextures/flextures_factory"

module Flextures
  # ActiveRecord Model is created that guess by table_name
  def self.create_model table_name
    # when Model is defined in FactoryFilter
    a = ->{
      f = Factory::FACTORIES[table_name.to_sym]
      f && f[:model]
    }
    # when program can guess Model name by table_name
    b = ->{
      begin
        table_name.singularize.camelize.constantize
      rescue => e
        nil
      end
    }
    # when cannot guess Model name
    c = ->{ 
      Class.new(ActiveRecord::Base){ |o| o.table_name=table_name }
    }
    a.call || b.call || c.call
  end

  # load configuration file, if file is exist
  def self.init_load
    if defined?(Rails) and Rails.root
      [
        "#{Rails.root.to_path}/config/flextures.config.rb",
        "#{Rails.root.to_path}/config/flextures.factory.rb",
      ].each { |fn| load(fn) if File.exist?(fn) }
    end
  end

  # 全テーブル削除のときにほんとうに消去して良いテーブル一覧を返す
  def self.deletable_tables
    tables = ActiveRecord::Base.connection.tables
    Flextures::Config.ignore_tables.each do |name|
      tables.delete name
    end
    tables
  end

  # initialize table data
  def self.init_tables
    tables = Flextures::deletable_tables
    tables.each do |name|
      # テーブルではなくviewを拾って止まる場合があるのでrescueしてしまう
      begin
        Class.new(ActiveRecord::Base){ |o| o.table_name= name }.delete_all
      rescue => e
      end
    end
  end

  def self.delete_tables *tables
    tables.each do |name|
      # テーブルではなくviewを拾って止まる場合があるのでrescueしてしまう
      begin
        Class.new(ActiveRecord::Base){ |o| o.table_name= name }.delete_all
      rescue => e
      end
    end
  end

  # デバッグ用のメソッド、渡されたブロックを実行する
  # 主にテーブルの今の中身を覗きたい時に使う
  def self.table_tap &dumper
    tables = Flextures::deletable_tables
    tables.each do |name|
      # テーブルではなくviewを拾って止まる場合があるのでrescueしてしまう
      begin
        klass = Class.new(ActiveRecord::Base){ |o| o.table_name= name; }
        dumper.call klass
      rescue => e
      end
    end
  end

  # parse arguments functions
  module ARGS
    # parse rake ENV parameters
    def self.parse option={}
      table_names = []
      if v = (ENV["T"] or ENV["TABLE"])
        table_names = v.split(',').map{ |name| { table: name, file: name } }
      end
      if v = (ENV["M"] or ENV["MODEL"])
        table_names = v.split(',').map do |name|
          name = name.constantize.table_name
          { table: name, file: name }
        end
      end

      table_names = Flextures::deletable_tables.map{ |name| { table: name, file: name } } if table_names.empty?

      # parse ENV["FIXTURES"] paameter
      fixtures_args_parser =->(s){
        names = s.split(',')
        if ENV["TABLE"] or ENV["T"] or ENV["MODEL"] or ENV["M"]
          [ table_names.first.merge( file: names.first ) ]
        else
          names.map{ |name| { table: name, file: name } }
        end
      }
      # parse filename define parameters
      table_names = fixtures_args_parser.call ENV["FIXTURES"] if ENV["FIXTURES"]
      table_names = fixtures_args_parser.call ENV["FILE"]     if ENV["FILE"]
      table_names = fixtures_args_parser.call ENV["F"]        if ENV["F"]

      table_names = table_names.map{ |option| option.merge dir: ENV["DIR"] } if ENV["DIR"]
      table_names = table_names.map{ |option| option.merge dir: ENV["D"]   } if ENV["D"]

      table_names = table_names.map{ |option| option.merge minus: ENV["MINUS"].to_s.split(",") } if ENV["MINUS"]
      table_names = table_names.map{ |option| option.merge plus:  ENV["PLUS"].to_s.split(",")  } if ENV["PLUS"]

      table_names = table_names.map{ |option| option.merge silent: true }   if ENV["OPTIONS"].to_s.split(",").include?("silent")
      table_names = table_names.map{ |option| option.merge unfilter: true } if ENV["OPTIONS"].to_s.split(",").include?("unfilter")

      # if mode is 'read mode' and file is not exist value is not return
      table_names.select! &exist if option[:mode] && option[:mode] == 'read'
      table_names
    end

    # check exist filename block
    def self.exist
      return->(name){ File.exists?( File.join( Config.fixture_load_directory, "#{name}.csv") ) or
                      File.exists?( File.join( Config.fixture_load_directory, "#{name}.yml") ) }
    end
  end
end

