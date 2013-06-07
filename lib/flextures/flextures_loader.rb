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
    @@option_cache = {}
    
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

    # load fixture datas
    #
    # 全テーブルが対象
    # flextures :all
    # テーブル名で一覧する
    # flextures :users, :items
    # ハッシュで指定
    # flextures :users => :users2
    #
    # @params [Hash] fixtures load table data
    def self.flextures *fixtures
      load_list = parse_flextures_options(*fixtures)
      load_list.sort &self.loading_order
      load_list.each{ |params| Loader::load params }
    end

    # @return [Proc] order rule block (user Array#sort_by methd)
    def self.loading_order
      ->(a,b){
        a = Flextures::Config.table_load_order.index(a) || -1
        b = Flextures::Config.table_load_order.index(b) || -1
        b <=> a
      }
    end
    
    # called by Rspec or Should
    # set options
    # @params [Hash] options exmple : { cashe: true, dir: "models/users" }
    def self.set_options options
      @@option_cache ||= {}
      @@option_cache.merge!(options)
    end

    # called by Rspec or Should after filter
    # reflesh options
    def self.delete_options
      @@option_cache = {}
    end

    # return current option status
    # @return [Hash] current option status
    def self.flextures_options
      @@option_cache
    end

    # load fixture data
    # fixture file prefer YAML to CSV
    # @params [Hash] format file load format(table name, file name, options...)
    def self.load format
      file_name, method = file_exist format
      if method
        send(method, format)
      else
        puts "Warning: #{file_name} is not exist!" unless format[:silent]
      end
    end

    # load CSV data
    # @params [Hash] format file load format(table name, file name, options...)
    def self.csv format
      type = :csv
      file_name, ext = file_exist format, [type]

      return unless self.file_loadable? format, file_name

      klass, filter = self.create_model_filter format, file_name, type
      self.load_csv format, klass, filter, file_name
    end

    # load YAML data
    # @params [Hash] format file load format(table name, file name, options...)
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

    def self.parse_controller_option options
      controller_dir = ["controllers"]
      controller_dir<< options[:controller] if options[:controller]
      controller_dir<< options[:action]     if options[:controller] and options[:action]
      File.join(*controller_dir)
    end

    def self.parse_model_options options
      model_dir = ["models"]
      model_dir<< options[:model]  if options[:model]
      model_dir<< options[:method] if options[:model] and options[:method]
      File.join(*model_dir)
    end

    # flextures関数の引数をパースして
    # 単純な読み込み向け形式に変換します
    #
    # @params [Hash] 読み込むテーブルとファイル名のペア
    # @return [Array] 読み込テーブルごとに切り分けられた設定のハッシュを格納
    def self.parse_flextures_options *fixtures
      options = {}
      options = fixtures.shift if fixtures.size > 1 and fixtures.first.is_a?(Hash)

      options[:dir] = self.parse_controller_option( options ) if options[:controller]
      options[:dir] = self.parse_model_options( options )     if options[:model]

      # :all value load all loadable fixtures
      fixtures = Flextures::deletable_tables if fixtures.size==1 and :all == fixtures.first
      last_hash = fixtures.last.is_a?(Hash) ? fixtures.pop : {}
      load_hash = fixtures.inject({}){ |h,name| h[name.to_sym] = name.to_s; h } # symbolに値を寄せ直す
      load_hash.merge!(last_hash)
      load_hash.map { |k,v| { table: k, file: v, loader: :fun }.merge(@@option_cache).merge(options) }
    end

    # example:
    # self.create_stair_list("foo/bar/baz")
    # return ["foo/bar/baz","foo/bar","foo",""]
    def self.stair_list dir, stair=true
      return [dir.to_s] unless stair
      l = []
      dir.to_s.split("/").inject([]){ |a,d| a<< d; l.unshift(a.join("/")); a }
      l<< ""
      l
    end

    # どのファイルが存在するかチェック
    # @param [Hash] format ロードしたいファイルの情報
    # @return 存在するファイルの種類(csv,yml)、どちも存在しないならnil
    def self.file_exist format, type = [:csv,:yml]
      table_name = format[:table].to_s
      file_name = (format[:file] || format[:table]).to_s
      base_dir_name = Flextures::Config.fixture_load_directory
      self.stair_list(format[:dir], format[:stair]).each do |dir|
        file_path = File.join( base_dir_name, dir, file_name )
        return ["#{file_path}.csv", :csv] if type.member?(:csv) and File.exist? "#{file_path}.csv"
        return ["#{file_path}.yml", :yml] if type.member?(:yml) and File.exist? "#{file_path}.yml"
      end

      [ File.join(base_dir_name, "#{file_name}.csv"), nil ]
    end

    def self.file_loadable? format, file_name
      table_name = format[:table].to_s.to_sym
      # if table data is loaded, use cached data
      return if format[:cache] and @@table_cache[table_name] == file_name
      @@table_cache[table_name] = file_name
      return unless File.exist? file_name
      puts "try loading #{file_name}" if !format[:silent] and ![:fun].include?(format[:loader])
      true
    end

    # print warinig message that lack or not exist colum names
    def self.warning format, attributes, keys
      (attributes-keys).each { |name| puts "Warning: #{format} colum is missing! [#{name}]" }
      (keys-attributes).each { |name| puts "Warning: #{format} colum is left over! [#{name}]" }
    end

    # create filter and table info
    def self.create_model_filter format, file_name, type
      table_name = format[:table].to_s
      klass = PARENT::create_model table_name
      # if you use 'rails3_acts_as_paranoid' gem, that is not delete data 'delete_all' method
      klass.send (klass.respond_to?(:delete_all!) ? :delete_all! : :delete_all)
      filter = ->(h){
        filter = create_filter klass, LoadFilter[table_name.to_sym], file_name, type, format
        o = klass.new
        o = filter.call o, h
        o.save( validate: false )
        o
      }
      [klass, filter]
    end

    # フィクスチャから取り出した値を、加工して欲しいデータにするフィルタを作成して返す
    def self.create_filter klass, factory, filename, ext, options
      columns = klass.columns
      # data translat array to hash
      column_hash = columns.inject({}) { |h,col| h[col.name] = col; h }
      # 自動補完が必要なはずのカラム
      lack_columns = columns.reject { |c| c.null and c.default }.map{ |o| o.name.to_sym }
      # default value shound not be null columns
      not_nullable_columns = columns.reject(&:null).map &:name
      # 本来のfixtureの読み込み時のように
      # 値の保管などはしないで読み込み速度を特化しつつ
      # カラムのエラーなどは出来るだけそのまま扱う
      strict_filter=->(o,h){
        # if value is not 'nil', value translate suitable form
        h.each{ |k,v| v.nil? || o[k] = (TRANSLATER[column_hash[k].type] && TRANSLATER[column_hash[k].type].call(v)) }
        # call FactoryFilter
        factory.call(*[o, :load, filename, ext][0,factory.arity]) if factory and !options[:unfilter]
        o
      }
      # ハッシュを受け取って、必要な値に加工してからハッシュで返すラムダを返す
      loose_filter=->(o,h){
        h.reject! { |k,v| options[:minus].include?(k) } if options[:minus]
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

