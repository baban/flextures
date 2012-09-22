# encoding: utf-8

require 'ostruct'
require 'csv'

require "flextures/flextures_base_config"
require "flextures/flextures_extension_modules"
require "flextures/flextures_factory"

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

  # 全テーブル削除のときにほんとうに消去して良いテーブル一覧を返す
  def self.deletable_tables
    tables = ActiveRecord::Base.connection.tables
    Flextures::Config.ignore_tables.each do |name|
      tables.delete name
    end
    tables
  end

  # テーブル情報の初期化
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

  # テーブル情報の初期化
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

  # 引数解析
  module ARGS
    # 書き出し 、読み込み すべきファイルとオプションを書きだす
    def self.parse option={}
      table_names = []
      if ENV["T"] or ENV["TABLE"]
        table_names = (ENV["T"] or ENV["TABLE"]).split(',').map{ |name| { table: name, file: name } }
      end
      if ENV["M"] or ENV["MODEL"]
        table_names = (ENV["M"] or ENV["MODEL"]).split(',').map do |name|
          name = name.constantize.table_name
          { table: name, file: name }
        end
      end

      if table_names.empty?
        table_names = Flextures::deletable_tables.map{ |table| { table: table } }
      end
      # ENV["FIXTURES"]の中身を解析
      fixtures_args_parser =->(s){
        names = s.split(',')
        ( names.size==1 and ENV.values_at("M", "MODEL", "T", "TABLE").first ) ?
          [ table_names.first.merge( file: names.first ) ] :
          names.map{ |name| { table: name, file: name } }
      }
      # ファイル名を調整
      table_names = fixtures_args_parser.call ENV["FIXTURES"] if ENV["FIXTURES"]
      table_names = fixtures_args_parser.call ENV["FILE"]     if ENV["FILE"]

      table_names = table_names.map{ |option| option.merge dir: ENV["DIR"] } if ENV["DIR"]
      # read mode だとcsvもyaml存在しないファイルは返さない
      table_names.select! &exist if option[:mode] && option[:mode] == 'read'
      table_names
    end

    # 存在しているファイルで絞り込む
    def self.exist
      return->(name){ File.exists?("#{LOAD_DIR}#{name}.csv") or File.exists?("#{LOAD_DIR}#{name}.yml") }
    end
  end
end

