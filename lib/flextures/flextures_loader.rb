# encoding: utf-8

require 'ostruct'
require 'csv'

require 'flextures/flextures_base_config'
require 'flextures/flextures_extension_modules'
require 'flextures/flextures'
require 'flextures/flextures_factory'

module Flextures
  # data loader
  module Loader 
    PARENT = Flextures

    @@table_cache = {}

    # column set default value
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

    # colum data translate
    TRANSLATER = {
      binary:->(d){
        return d if d.nil?
        Base64.decode64(d)
      },
      boolean:->(d){
        return d if d.nil?
        !(0==d || ""==d || !d)
      },
      date:->(d){
        return d   if d.nil?
        return nil if d==""
        Date.parse(d.to_s)
      },
      datetime:->(d){
        return d   if d.nil?
        return nil if d==""
        DateTime.parse(d.to_s)
      },
      decimal:->(d){
        return d if d.nil?
        d.to_i
      },
      float:->(d){
        return d if d.nil?
        d.to_f
      },
      integer:->(d){
        return d if d.nil?
        d.to_i
      },
      string:->(d){
        return d if d.nil? or d.is_a?(Hash) or d.is_a?(Array)
        d.to_s
      },
      text:->(d){
        return d if d.nil? or d.is_a?(Hash) or d.is_a?(Array)
        d.to_s
      },
      time:->(d){
        return d   if d.nil?
        return nil if d==""
        DateTime.parse(d.to_s)
      },
      timestamp:->(d){
        return d   if d.nil?
        return nil if d==""
        DateTime.parse(d.to_s)
      },
    }

    # どのファイルが存在するかチェック
    # @param [Hash] format ロードしたいファイルの情報
    # @return 存在するファイルの種類(csv,yml)、どちも存在しないならnil
    def self.file_exist format, type = [:csv,:yml]
      table_name = format[:table].to_s
      file_name = format[:file] || format[:table]
      dir_name = format[:dir] || Flextures::Config.fixture_load_directory

      ext=->{
        if    type.member?(:csv) and File.exist? File.join( dir_name, "#{file_name}.csv" )
          :csv
        elsif type.member?(:yml) and File.exist? File.join( dir_name, "#{file_name}.yml" )
          :yml
        else
          nil
        end
      }.call

      [(ext && "#{dir_name}#{file_name}.#{ext}"),ext]
    end
    
    # flextures関数の引数をパースして
    # 単純な読み込み向け形式に変換します
    #
    # @params [Hash] 読み込むテーブルとファイル名のペア
    # @return [Array] 読み込テーブルごとに切り分けられた設定のハッシュを格納
    def self.parse_flextures_options *fixtures
      options = {}
      options = fixtures.shift if fixtures.size > 1 and fixtures.first.is_a?(Hash)

      # :all value load all loadable fixtures
      fixtures = Flextures::deletable_tables if fixtures.size==1 and :all == fixtures.first

      last_hash = fixtures.last.is_a?(Hash) ? fixtures.pop : {}
      load_hash = fixtures.inject({}){ |h,name| h[name.to_sym] = name; h } # symbolに値を寄せ直す
      load_hash.merge!(last_hash)
      load_hash = load_hash.map { |k,v| { table: k, file: v, loader: :fun } }
      [load_hash, options]
    end

    # fixturesをまとめてロード、主にテストtest/unit, rspec で使用する
    #
    # 全テーブルが対象
    # flextures :all
    # テーブル名で一覧する
    # flextures :users, :items
    # ハッシュで指定
    # flextures :users => :users2
    #
    # @params [Hash] 読み込むテーブルとファイル名のペア
    def self.flextures *fixtures
      load_hash, options = parse_flextures_options(*fixtures)
      load_hash.each{ |params| Loader::load params }
    end

    # csv 優先で存在している fixtures をロード
    def self.load format
      file_name, method = file_exist format
      if method
        send(method, format)
      else
        # ファイルが存在しない時
        puts "Warning: #{file_name} is not exist!" unless format[:silent]
      end
    end

    # load CSV data
    def self.csv format
      type = :csv
      file_name, ext = file_exist format, [type]

      return unless self.file_loadable? format, file_name

      klass, filter = self.create_model_filter format, file_name, type

      self.load_csv format, klass, filter, file_name
    end

    # YAML形式でデータをロードする
    def self.yml format
      type = :yml
      file_name, ext = file_exist format, [type]

      return unless self.file_loadable? format, file_name

      klass, filter = self.create_model_filter format, file_name, type

      self.load_yml format, klass, filter, file_name
    end

    def self.load_csv format, klass, filter, file_name
      attributes = klass.columns.map &:name
      CSV.open( file_name ) do |csv|
        keys = csv.shift # keyの設定
        warning "CSV", attributes, keys unless format[:silent]
        csv.each do |values|
          h = values.extend(Extensions::Array).to_hash(keys)
          filter.call h
        end
      end
      file_name
    end

    def self.load_yml format, klass, filter, file_name
      yaml = YAML.load File.open(file_name)
      return false unless yaml # if file is empty
      attributes = klass.columns.map &:name
      yaml.each do |k,h|
        warning "YAML", attributes, h.keys unless format[:silent]
        filter.call h
      end
      file_name
    end

    def self.file_loadable? format, file_name
      table_name = format[:table].to_s.to_sym
      # キャッシュ利用可能ならそれをそのまま使う
      return nil if format[:cache] and @@table_cache[table_name] == file_name
      @@table_cache[table_name] = file_name
      return nil unless File.exist? file_name
      puts "try loading #{file_name}" if !format[:silent] and ![:fun].include?(format[:loader])
      true
    end

    # create filter and table info
    def self.create_model_filter format, file_name, type
      table_name = format[:table].to_s
      klass = PARENT::create_model table_name
      # if you use 'rails3_acts_as_paranoid' gem, that is not delete data 'delete_all' method
      klass.send (klass.respond_to?(:delete_all!) ? :delete_all! : :delete_all)
      filter = self.create_object_filter klass, LoadFilter[table_name], file_name, type, format
      [klass, filter]
    end

    # print warinig message that lack or not exist colum names
    def self.warning format, attributes, keys
      (attributes-keys).each { |name| puts "Warning: #{format} colum is missing! [#{name}]" }
      (keys-attributes).each { |name| puts "Warning: #{format} colum is left over! [#{name}]" }
    end

    # フィルタを適応してデータを保存する処理
    def self.create_object_filter klass, filter_base, file_name, ext, options
      filter = create_filter klass, filter_base, file_name, ext, options
      return ->(h){
        o = klass.new
        o = filter.call o, h
        o.save( validate: false )
        o
      }
    end

    # フィクスチャから取り出した値を、加工して欲しいデータにするフィルタを作成して返す
    def self.create_filter klass, factory, filename, ext, options
      columns = klass.columns
      # delete unload columns
      columns.reject! { |col| options[:minus].include?(col.name) } if options[:minus]
      # data translat array to hash
      column_hash = columns.inject({}) { |h,col| h[col.name] = col; h }
      # 自動補完が必要なはずのカラム
      lack_columns = columns.reject { |c| c.null and c.default }.map{ |o| o.name.to_sym }
      not_nullable_columns = columns.reject(&:null).map &:name
      # 本来のfixtureの読み込み時のように
      # 値の保管などはしないで読み込み速度を特化しつつ
      # カラムのエラーなどは出来るだけそのまま扱う
      strict_filter=->(o,h){
        # 値がnilでないなら型をDBで適切なものに変更
        h.each{ |k,v| v.nil? || o[k] = (TRANSLATER[column_hash[k].type] && TRANSLATER[column_hash[k].type].call(v)) }
        # call FactoryFilter
        factory.call(*[o, :load, filename, ext][0,factory.arity]) if factory and !options[:unfilter]
        o
      }
      # ハッシュを受け取って、必要な値に加工してからハッシュで返すラムダを返す
      loose_filter=->(o,h){
        # h.reject! { |k,v| options[:minus].include?(k) } if options[:minus]
        # テーブルに存在しないキーが定義されているときは削除
        h.select! { |k,v| column_hash[k] }
        strict_filter.call(o,h)
        # set default value if value is 'nil'
        not_nullable_columns.each{ |k| o[k].nil? && o[k] = (column_hash[k] && COMPLETER[column_hash[k].type] && COMPLETER[column_hash[k].type].call) }
        # fill span values if column is not exist
        lack_columns.each { |k| o[k].nil? && o[k] = (column_hash[k] && COMPLETER[column_hash[k].type] && COMPLETER[column_hash[k].type].call) }
        o
      }
      (options[:strict]==true) ? strict_filter : loose_filter
    end
  end
end

