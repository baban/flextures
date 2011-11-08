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
    klass = Class.new ActiveRecord::Base
    klass.table_name=table_name
    klass
  end
  
  def self.init_load
    if defined?(Rails) and Rails.root
      [
        "#{Rails.root.to_path}/config/flextures.config.rb",
        "#{Rails.root.to_path}/config/flextures.factory.rb",
      ].each { |fn| load(fn) if File.exist?(fn) }
    end
  end

  # 引数解析
  module ARGS
    # 書き出し 、読み込み すべきファイルとオプションを書きだす
    def self.parse option={}
      Flextures::init_load
      table_names = ""
      table_names = ENV["TABLE"].split(",") if ENV["TABLE"]
      table_names = ENV["T"].split(",") if ENV["T"]
      table_names = ENV["MODEL"].constantize.table_name.split(",") if ENV["MODEL"]
      table_names = ENV["M"].constantize.table_name.split(",") if ENV["M"]
      table_names = ActiveRecord::Base.connection.tables if ""==table_names
      table_names = table_names.map{ |name| { table: name } }
      table_names = table_names.map{ |option| option.merge dir: ENV["DIR"] } if ENV["DIR"]
      table_names.first[:file]= ENV["FIXTURES"] if ENV["FIXTURES"] # ファイル名は最初のものしか指定できない
      table_names.first[:file]= ENV["F"] if ENV["F"]
      # read mode だとcsvもyaml存在しないファイルは返さない
      table_names.select! &exist if option[:mode] && option[:mode].to_sym == :read 
      table_names
    end

    # 存在しているファイルで絞り込む　    
    def self.exist
      return->(name){ File.exists?("#{LOAD_DIR}#{name}.csv") or File.exists?("#{LOAD_DIR}#{name}.yml") }
    end
  end
  
  module Dumper
    PARENT = Flextures

    # 適切な型に変換
    def self.trans v
      case v
        when true;  1
        when false; 0
        else; v
      end
    end

    # csv で fixtures を dump 
    def self.csv format
      table_name = format[:table]
      file_name = format[:file] || table_name
      dir_name = format[:dir] || DUMP_DIR
      outfile = "#{dir_name}#{file_name}.csv"
      klass = PARENT.create_model(table_name)
      attributes = klass.columns.map { |colum| colum.name }

      CSV.open(outfile,'w') do |csv|
        csv<< attributes
        klass.all.each do |row|
          csv<< attributes.map { |column| trans(row.send(column))}
        end
      end
    end

    # yaml で fixtures を dump 
    def self.yml format
      table_name = format[:table]
      file_name = format[:file] || table_name
      dir_name = format[:dir] || DUMP_DIR
      outfile = "#{dir_name}#{file_name}.yml"
      klass = PARENT::create_model(table_name)
      attributes = klass.columns.map { |colum| colum.name }

      File.open(outfile,"w") do |f|
        klass.all.each_with_index do |row,idx| 
          f<< "#{table_name}_#{idx}:\n" +
            attributes.map { |column|
              v = trans row.send(column)
              "  #{column}: #{v}\n"
            }.join
        end
      end
    end
  end

  module Loader 
    PARENT = Flextures

    # 型に応じて勝手にdefault値を設定する
    COMPLETER = {
      binary:->{ 0 },
      boolean:->{ false },
      date:->{ DateTime.now },
      datetime:->{ DateTime.now },
      decimal:->{ 0 },
      float:->{ 0.0 },
      integer:->{ 0 },
      string:->{ "" },
      text:->{ "" },
      time:->{ DateTime.now },
      timestamp:->{ DateTime.now },
    }
    
    # 型の変換を行う
    TRANSLATER = {
      binary:->(d){ d.to_i },
      boolean:->(d){ (0==d || ""==d || !d) ? false : true },
      date:->(d){ Date.parse(d.to_s) },
      datetime:->(d){ DateTime.parse(d.to_s) },
      decimal:->(d){ d.to_i },
      float:->(d){ d.to_f },
      integer:->(d){ d.to_i },
      string:->(d){ d.to_s },
      text:->(d){ d.to_s },
      time:->(d){ DateTime.parse(d.to_s) },
      timestamp:->(d){ DateTime.parse(d.to_s) },
    }

    # csv 優先で存在している fixtures をロード
    def self.load format
      file_name = format[:file] || format[:table]
      dir_name = format[:dir] || LOAD_DIR
      method = nil
      method = :csv if File.exist? "#{dir_name}#{file_name}.csv"
      method = :yml if File.exist? "#{dir_name}#{file_name}.yml"
      self::send(method, format) if method
    end

    # fixturesをまとめてロード、主にテストtest/unit, rspec で使用する    
    def self.flextures *fixtures
      PARENT::init_load
      # :allですべてのfixtureを反映
      fixtures = ActiveRecord::Base.connection.tables if fixtures.size== 1 and :all == fixtures.first
      
      fixtures_hash = fixtures.pop if fixtures.last and fixtures.last.is_a? Hash # ハッシュ取り出し
      fixtures.each{ |table_name| Loader::load table: table_name }
      fixtures_hash.each{ |k,v| Loader::load table: k, file: v } if fixtures_hash
      fixtures
    end

    # CSVのデータをロードする
    def self.csv format
      table_name = format[:table].to_s
      file_name = format[:file] || table_name
      dir_name = format[:dir] || LOAD_DIR
      inpfile = "#{dir_name}#{file_name}.csv"

      klass = PARENT::create_model table_name
      attributes = klass.columns.map &:name
      filter = create_filter klass.columns, Factory[table_name]
      klass.delete_all
      CSV.open( inpfile ) do |csv|
        keys = csv.shift # keyの設定
        warning "CSV", attributes, keys
        csv.each do |values|
          klass.create filter.call values.extend(Extensions::Array).to_hash(keys)
        end
      end
    end

    # YAML形式でデータをロードする
    def self.yml format
      table_name = format[:table].to_s
      file_name = format[:file] || table_name
      dir_name = format[:dir] || LOAD_DIR
      inpfile = "#{dir_name}#{file_name}.yml"

      klass = PARENT::create_model table_name
      attributes = klass.columns.map &:name
      filter = create_filter klass.columns, Factory[table_name]
      klass.delete_all
      YAML.load(File.open(inpfile)).each do |k,h|
        warning "YAML", attributes, h.keys
        klass.create filter.call h
      end
    end
    
    # 欠けたカラムを検知してメッセージを出しておく
    def self.warning format, attributes, keys
      (attributes-keys).each { |name| print "Warning: #{format} colum is missing! [#{name}]\n" }
      (keys-attributes).each { |name| print "Warning: #{format} colum is left over! [#{name}]\n" }
    end

    # フィクスチャから取り出した値を、加工して欲しいデータにするフィルタを作成して返す
    def self.create_filter columns, factory=nil
      # テーブルからカラム情報を取り出し
      column_hash = {}
      columns.each { |col| column_hash[col.name] = col }
      # 自動補完が必要なはずのカラム
      lack_columns = columns.select { |c| !c.null and !c.default }.map &:name
      # ハッシュを受け取って、必要な値に加工してからハッシュで返すラムダを返す
      return->(h){
        h.select! { |k,v| column_hash[k] } # テーブルに存在しないキーが定義されているときは削除
        # 値がnilでないなら型をDBで適切なものに変更
        h.each{ |k,v| nil==v || h[k] = TRANSLATER[column_hash[k].type].call(v) }
        # FactoryFilterを動作させる
        st = OpenStruct.new(h)
        factory.call(st) if factory
        h = st.to_hash
        # 値がnilの列にデフォルト値を補間
        lack_columns.each { |k| nil==h[k] && h[k] = COMPLETER[column_hash[k].type].call }
        h
      }
    end

  end
end

