require 'ostruct'
require 'csv'
require 'erb'
require 'smarter_csv'

require 'active_record'

require 'flextures/flextures_base_config'
require 'flextures/flextures'
require 'flextures/flextures_factory'

module Flextures
  # data loader
  class Loader
    module ArrayEx
      refine Array do
        # @params [Array] keys hash keys
        # @return [Hash] tanslated Hash data
        def to_hash(keys)
          values = self
          values = values[0..keys.size-1]                   if keys.size < values.size
          values = values + [nil] * (keys.size-values.size) if keys.size > values.size
          [keys, values].transpose.reduce({}){ |h,(k,v)| h[k]=v; h }
        end
      end
    end
    using ArrayEx

    module TableColumnEx
      refine ActiveRecord::ConnectionAdapters::Column do
        def translater(klass)
          type_name = klass.defined_enums[name.to_s] ? :enum : type
          TRANSLATER[type_name]
        end

        def completer(klass)
          type_name = klass.defined_enums[name.to_s] ? :enum : type
          COMPLETER[type_name]
        end
      end
    end
    using TableColumnEx

    PARENT = Flextures
    FORMATS = [ %i[csv erb], %i[erb csv], %i[csv], %i[yml erb], %i[erb yml], %i[yml] ]

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
        !("FALSE"==d || "false"==d || "0"==d || ""==d || 0==d || !d)
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
      enum:->(v){
        return v.to_i if v.match(/^\d+$/)
        v
      }
    }

    def initialize(*_)
      # 読み込み状態を持っておく
      @options = {}
      @already_loaded_fixtures = {}
    end

    def loads(*fixtures)
      # キャッシュが有効 ∧ 呼んだ事無いファイル
      load_list = self.class.parse_flextures_options(@options, *fixtures)
      load_list.sort(&self.class.loading_order).each do |params|
        load(params)
      end
    end

    def load(params)
      self.class.load(params)
    end

    def self.cache?(params)
      return unless params.first.is_a?(Hash)

      param = params.first
      param[:cache] == true
    end

    # compare
    def equal_table_data?(src, dst)
      return false unless src.is_a?(Hash)
      return false unless dst.is_a?(Hash)

      (src.to_a - dst.to_a).empty?
    end

    # called by Rspec or Should
    # set options
    # @params [Hash] options exmple : { cashe: true, dir: "models/users" }
    def set_options(options)
      @options.merge!(options)
    end

    # called by Rspec or Should after filter
    # reflesh options
    def delete_options
      @options = {}
    end

    # return current option status
    # @return [Hash] current option status
    def flextures_options
      @options
    end

    # parse flextures function arguments
    # @params [Hash] fixtures function arguments
    # @return [Array] formatted load options
    def self.parse_flextures_options(base_options, *fixtures)
      options = {}
      options = fixtures.shift if fixtures.size > 1 and fixtures.first.is_a?(Hash)

      options[:dir] = self.parse_controller_option(options) if options[:controller]
      options[:dir] = self.parse_model_options(options)     if options[:model]

      # :all value load all loadable fixtures
      fixtures = Flextures::deletable_tables if fixtures.size==1 and :all == fixtures.first
      last_hash = fixtures.last.is_a?(Hash) ? fixtures.pop : {}
      load_hash = fixtures.reduce({}){ |h,name| h[name.to_sym] = name.to_s; h } # if name is string is buged
      load_hash.merge!(last_hash)
      load_hash.map { |k,v| { table: k, file: v, loader: :fun }.merge(base_options).merge(options) }
    end

    # load fixture datas
    #
    # example:
    # flextures :all # load all table data
    # flextures :users, :items # load table data, received arguments
    # flextures :users => :users2 # :table_name => :file_name
    #
    # @params [Hash] fixtures load table data
    def self.flextures(*fixtures)
      loader = Flextures::Loader::Instance.new
      loader.loads(*fixtures)
    end

    # @return [Proc] order rule block (user Array#sort methd)
    def self.loading_order
      ->(a,b) do
        a = Flextures::Configuration.table_load_order.index(a) || -1
        b = Flextures::Configuration.table_load_order.index(b) || -1
        b <=> a
      end
    end

    # load fixture data
    # fixture file prefer YAML to CSV
    # @params [Hash] format file load format(table name, file name, options...)
    def self.load(format, type = %i[csv yml])
      file_name, *exts = file_exist(format, type)
      format[:erb] = exts.include?(:erb)
      method = exts.find { |k| type.include?(k) }

      return unless self.file_loadable?(format, file_name)

      klass, filter = self.create_model_filter(format, file_name, method)

      case method
      when :csv
        self.load_csv(format, klass, filter, file_name)
      when :yml
        self.load_yml(format, klass, filter, file_name)
      else
        puts "Warning: #{file_name} is not exist!" unless format[:silent]
      end
    end

    def self.load_file(format, file_name)
      file = nil
      if format[:erb]
        str = File.open(file_name){ |f| f.read }
        file = ERB.new(str).result
      else
        file = File.open(file_name)
      end
    end

    def self.load_csv(format, klass, filter, file_name)
      file = self.load_file(format, file_name)
      attributes = klass.columns.map(&:name)
      ActiveRecord::Base.transaction do
        csv = SmarterCSV.process(file.path)
        keys = csv.first.keys.map(&:to_s)
        warning("CSV", attributes, keys) unless format[:silent]
        csv.each do |row|
          h = row.reduce({}){ |h,(k,v)| h[k.to_s]=v; h }
          o = filter.call(h)
          o.save(validate: false)
        end
      end
      file_name
    end

    def self.load_yml(format, klass, filter, file_name)
      file = self.load_file(format, file_name)
      yaml = YAML.load(file)

      return false unless yaml # if file is empty

      attributes = klass.columns.map(&:name)
      ActiveRecord::Base.transaction do
        yaml.each do |k,h|
          warning("YAML", attributes, h.keys) unless format[:silent]

          o = filter.call(h)
          o.save(validate: false)
        end
      end
      file_name
    end

    # if parameter include controller, action value
    # load directroy is change
    # spec/fixtures/:controller_name/:action_name/
    # @return [String] directory path
    def self.parse_controller_option(options)
      controller_dir = ["controllers"]
      controller_dir<< options[:controller] if options[:controller]
      controller_dir<< options[:action]     if options[:controller] and options[:action]
      File.join(*controller_dir)
    end

    # if parameter include controller, action value
    # load directroy is change
    # spec/fixtures/:model_name/:method_name/
    # @return [String] directory path
    def self.parse_model_options(options)
      model_dir = ["models"]
      model_dir<< options[:model]  if options[:model]
      model_dir<< options[:method] if options[:model] and options[:method]
      File.join(*model_dir)
    end

    # example:
    # self.create_stair_list("foo/bar/baz")
    # return ["foo/bar/baz","foo/bar","foo",""]
    def self.stair_list(dir, stair=true)
      return [dir.to_s] unless stair

      l = []
      dir.to_s.split("/").reduce([]){ |a,d| a<< d; l.unshift(a.join("/")); a }
      l<< ""
      l
    end

    # parse format option and return load file info
    # @param [Hash] format load file format informations
    # @return [Array] [file_name, filt_type(:csv or :yml)]
    def self.file_exist(format, type = %i[csv yml])
      table_name = format[:table].to_s
      file_name = (format[:file] || format[:table]).to_s
      base_dir_name = Flextures::Configuration.load_directory
      self.stair_list(format[:dir], format[:stair]).each do |dir|
        file_path = File.join(base_dir_name, dir, file_name)
        formats = FORMATS.select { |fmt| (type & fmt).present? }
        formats.each do |fmt|
          return ["#{file_path}.#{fmt.join('.')}", *fmt] if File.exist?("#{file_path}.#{fmt.join('.')}")
        end
      end
      ["#{File.join(base_dir_name, file_name)}.csv", nil]
    end

    # file load check
    # @return [Bool] lodable is 'true'
    def self.file_loadable?(format, file_name)
      return unless File.exist?(file_name)
      puts "try loading #{file_name}" if !format[:silent] and ![:fun].include?(format[:loader])
      true
    end

    # print warinig message that lack or not exist colum names
    def self.warning(format, attributes, keys)
      (attributes-keys).each { |name| puts "Warning: #{format} colum is missing! [#{name}]" }
      (keys-attributes).each { |name| puts "Warning: #{format} colum is left over! [#{name}]" }
    end

    # create filter and table info
    def self.create_model_filter(format, file_name, type)
      table_name = format[:table].to_s
      klass = PARENT::create_model(table_name)
      # if you use 'rails3_acts_as_paranoid' gem, that is not delete data 'delete_all' method
      klass.send(klass.respond_to?(:delete_all!) ? :delete_all! : :delete_all)

      filter = ->(h){
        filter = create_filter(klass, LoadFilter[table_name.to_sym], file_name, type, format)
        o = klass.new
        o = filter.call(o, h)
        o
      }
      [klass, filter]
    end

    # return flextures data translate filter
    # translate filter is some functions
    # 1. column value is fill, if colum is not nullable
    # 2. factory filter
    # @params [ActiveRecord::Base] klass ActiveRecord model data
    # @params [Proc] factory FactoryFilter
    # @params [String] filename
    # @params [Symbol] ext file type (:csv or :yml)
    # @params [Hash] options other options
    # @return [Proc] translate filter
    def self.create_filter(klass, factory, filename, ext, options)
      columns = klass.columns
      # data translate array to hash
      column_hash = columns.reduce({}) { |h,col| h[col.name] = col; h }
      translaters = column_hash.reduce({}){ |h,(k,col)| h[k] = col.translater(klass); h }
      strict_filter = ->(o,h){
        # if value is not 'nil', value translate suitable form
        h.each { |k,v| v.nil? || o[k] = translaters[k]&.call(v) }
        # call FactoryFilter
        factory.call(*[o, filename, ext][0, factory.arity]) if factory and !options[:unfilter]
        o
      }

      return strict_filter if options[:strict]==true

      lack_columns = columns.reject { |c| c.null and c.default }.map{ |o| o.name.to_sym }
      # default value shound not be null columns
      not_nullable_columns = columns.reject(&:null).map(&:name)
      completers = column_hash.reduce({}){ |h,(k,col)| h[k] = col.completer(klass); h }
      # receives hased data and translate ActiveRecord Model data
      # loose filter correct error values
      # strict filter don't correct errora values and raise error
      loose_filter = ->(o,h){
        h.reject! { |k,v| options[:minus].include?(k) } if options[:minus]
        # if column name is not include database table columns, those names delete
        h.select! { |k,v| column_hash[k] }
        strict_filter.call(o,h)
        # set default value if value is 'nil'
        not_nullable_columns.each { |k| o[k].nil? && o[k] = completers[k]&.call }
        # fill span values if column is not exist
        lack_columns.each { |k| o[k].nil? && o[k] = completers[k]&.call }
        o
      }
    end
  end
end
