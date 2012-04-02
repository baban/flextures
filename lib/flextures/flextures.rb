# encoding: utf-8

require 'ostruct'
require 'csv'

require 'flextures/flextures_base_config'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures_factory'

module Flextures
  LOAD_DIR = Config.fixture_load_directory
  DUMP_DIR = Config.fixture_dump_directory

  # テーブルモデルの作成
  def self.create_model table_name
    # Factoryにオプションで指定があった時
    a = ->{
      f = Factory::FACTORIES[table_name.to_sym]
      f && f[:model]
    }
    # テーブル名からモデル名が推測できるとき
    b = ->{
      begin
        table_name.singularize.camelize.constantize
      rescue => e
        nil
      end
    }
    # モデル名推測不可能なとき
    c = ->{ 
      Class.new(ActiveRecord::Base){ |o| o.table_name=table_name }
    }
    a.call || b.call || c.call
  end

  # 設定ファイルが存在すればロード
  def self.init_load
    if defined?(Rails) and Rails.root
      [
        "#{Rails.root.to_path}/config/flextures.config.rb",
        "#{Rails.root.to_path}/config/flextures.factory.rb",
      ].each { |fn| load(fn) if File.exist?(fn) }
    end
  end

  # テーブル情報の初期化
  def self.init_tables
    tables = ActiveRecord::Base.connection.tables
    tables.delete "schema_migrations"
    tables.each{ |name|
      # テーブルではなくviewを拾って止まる場合があるのでrescueしてしまう
      begin
        Class.new(ActiveRecord::Base){ |o| o.table_name= name }.delete_all
      rescue => e
      end
    }
  end

  # 引数解析
  module ARGS
    # 書き出し 、読み込み すべきファイルとオプションを書きだす
    def self.parse option={}
      table_names = []
      if ENV["T"] or ENV["TABLE"]
        table_names = (ENV["T"] or ENV["TABLE"]).split(',').map{ |name| { table: name } }
      end
      if ENV["M"] or ENV["MODEL"]
        table_names = (ENV["M"] or ENV["MODEL"]).split(',').map{ |name| { table: name.constantize.table_name } }
      end
      if table_names.empty?
        table_names = ActiveRecord::Base.connection.tables.map{ |name| { table: name } }
      end
      # ENV["FIXTURES"]の中身を解析
      fixtures_args_parser =->(s){
        names = s.split(',')
        ( names.size==1 and ENV.values_at("M", "MODEL", "T", "TABLE").first ) ?
          [ table_names.first.merge( file: names.first ) ] :
          names.map{ |name| { table: name, file: name } }
      }
      table_names = fixtures_args_parser.call ENV["FIXTURES"] if ENV["FIXTURES"]
      table_names = fixtures_args_parser.call ENV["F"] if ENV["F"]
      table_names = table_names.map{ |option| option.merge dir: ENV["DIR"] } if ENV["DIR"]
      # read mode だとcsvもyaml存在しないファイルは返さない
      table_names.select! &exist if option[:mode] && option[:mode].to_sym == :read
      table_names
    end

    # 存在しているファイルで絞り込む
    def self.exist
      return->(name){ File.exists?("#{LOAD_DIR}#{name}.csv") or File.exists?("#{LOAD_DIR}#{name}.yml") }
    end
  end
end

