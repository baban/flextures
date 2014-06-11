# encoding: utf-8

require "fileutils"

module Flextures
  # defined data dump methods
  module Dumper
    PARENT = Flextures
    # procに機能追加、関数合成のためのメソッドを追加する
    class Proc < ::Proc
      def *(other)
        if self.lambda? and other.lambda?
          lambda { |*x| other.call(self.call(*x)) }
        elsif not self.lambda? and not other.lambda?
          Proc.new {|*x| other.call(self.call(*x)) }
        else
          raise ArgumentError, "lambda/Proc type mismatch"
        end
      end
    end

    def self.proc(&b)
      Proc.new(&b)
    end

    # create data translater
    def self.translate_creater( val, rules )
      rule_map = {
        nullstr: proc { |d|
          return "null" if d.nil?
          d
        },
        null: proc { |d|
          return nil if d.nil?
          d
        },
        blank2null: proc { |d|
          return "null" if d==""
          d
        },
        blankstr: proc { |d|
          return '""' if d==""
          d
        },
        false2nullstr: proc { |d|
          return "null" if d==false
          d
        },
        blank2num: proc { |d|
          return 0 if d==""
          d
        },
        null2blankstr: proc { |d|
          return "" if d.nil?
          d
        },
        bool2num: proc { |d|
          return 0 if d==false
          return 1 if d==true
          d
        },
        ymlspecialstr: proc { |s|
          if s.kind_of?(String)
            s = s.gsub(/\t/,"  ") if s["\t"]
            s = s.sub(/ +/, "")   if s[0]==' '
            is_nl = false
            is_nl |= s["\n"]
            is_nl |= ["[","]","{","}","|","#","@","~","!","'","$","&","^","<",">","?","-","+","=",";",":",".",",","*","`","(",")"].member?(s[0])
            s = s.gsub(/\r\n/,"\n").gsub(/\r/,"\n") # 改行方法統一
            s = "|-\n    " + s.gsub(/\n/,"\n    ") if is_nl
          end
          s
        },
        ymlnulltime: proc { |d|
          return "null" if d.nil? or d=="" or d==false
          d
        },
      }
      procs = rules.reduce(proc{ |d| d }) { |sum,i| sum * (rule_map[i] || i) }
      procs.call(val)
    end

    # data translaters
    TRANSLATER = {
      binary:->( d, format ){
        procs = (format == :yml)?
          [:nullstr, :null, proc { |d| Base64.encode64(d) } ] :
          [:null, proc { |d| Base64.encode64(d) } ]
        self.translate_creater( d, procs )
      },
      boolean:->( d, format ){
        procs = (format == :yml) ?
          [ :nullstr, proc { !(0==d || ""==d || !d) } ] :
          [ proc { !(0==d || ""==d || !d) } ]
        self.translate_creater( d, procs )
      },
      date:->( d, format ){
        procs = (format == :yml) ?
          [:nullstr, :blank2null, :false2nullstr, proc { |d| d.to_s }] :
          [proc { |d| d.to_s }]
        self.translate_creater d, procs
      },
      datetime:->( d, format ){
        procs = (format == :yml) ?
          [:nullstr, :blank2null, :false2nullstr, proc { |d| d.to_s }] :
          [proc { |d| d.to_s }]
        self.translate_creater d, procs
      },
      decimal:->( d, format ){
        procs = (format == :yml) ?
          [:nullstr, :blank2num, :bool2num, proc { |d| d.to_f } ] :
          [:null2blankstr, :bool2num, proc { |d| d.to_f } ]
        self.translate_creater d, procs
      },
      float:->(d, format){
        procs = (format == :yml) ?
          [:nullstr, :blank2num, :bool2num, proc { |d| d.to_f } ] :
          [:null2blankstr, :bool2num, proc { |d| d.to_f } ]
        self.translate_creater d, procs
      },
      integer:->( d, format ){
        procs = (format == :yml) ?
          [:nullstr, :blank2num, :bool2num, proc { |d| d.to_i } ] :
          [:null2blankstr, :bool2num, proc { |d| d.to_i } ]
        self.translate_creater d, procs
      },
      string:->( d, format ){
        procs = (format == :yml) ?
          [:blankstr, :nullstr, :ymlspecialstr] :
          [:null, proc{ |s| s.to_s.gsub(/\r\n/,"\n").gsub(/\r/,"\n") } ]
        self.translate_creater d, procs
      },
      text:->( d, format ){
        procs = (format == :yml) ?
          [:blankstr, :nullstr, :ymlspecialstr] :
          [:null, proc{ |s| s.to_s.gsub(/\r\n/,"\n").gsub(/\r/,"\n") } ]
        self.translate_creater d, procs
      },
      time:->( d, format ){
        procs = (format == :yml) ?
          [:ymlnulltime, proc { |d| d.to_s }] :
          [proc { |d| d.to_s }]
        self.translate_creater d, procs
      },
      timestamp:->( d, format ){
        procs = (format == :yml) ?
          [:ymlnulltime, proc { |d| d.to_s }] :
          [proc { |d| d.to_s }]
        self.translate_creater d, procs
      },
      # use null only value
      null:->( d, format ){
        format==:yml ? "null" : ""
      },
    }

    # translate data
    # @params [Object] value
    # @params [Symbol] type datatype
    # @params [Symbol] format data type (:yml or :csv)
    # @return translated value
    def self.trans( v, type, format )
      trans = TRANSLATER[type]
      return trans.call( v, format ) if trans
      v
    end

    # dump attributes data
    # @params klass dump table Model
    # @params [Hash] options dump options
    # @return [Array] columns format information
    def self.dump_attributes( klass, options )
      columns = klass.columns.map { |column| { name: column.name, type: column.type } }
      # option[:minus] colum is delete columns
      columns.reject! { |column| options[:minus].include?(column[:name]) } if options[:minus]
      # option[:plus] colum is new columns
      # values is all nil
      plus = options[:plus].to_a.map { |colname| { name: colname, type: :null } }
      columns + plus
    end

    # filter is translate value safe YAML or CSV string
    # @params [Class] klass ActiveRecord class
    # @params [String] table_name table name
    # @params [Hash] options options
    # @params [Symbol] type format type (:yml or :csv)
    # @return [Proc] filter function
    def self.create_filter( attr_type, format, type )
      filter = DumpFilter[format[:table].to_s.to_sym] || {}
      ->(row) {
        attr_type.map do |h|
          v = filter[h[:name].to_sym] ? filter[h[:name].to_sym].call(row[h[:name]]) : trans(row[h[:name]], h[:type], type)
          [h[:name],v]
        end
      }
    end

    # data dump to csv format
    # @params [Hash] format file format data
    # @params [Hash] options dump format options
    def self.csv( format )
      klass = PARENT.create_model(format[:table])
      attr_type = self.dump_attributes klass, format
      filter = self.create_filter attr_type, format, :csv
      self.dump_csv klass, attr_type, filter, format
    end

    # dump csv format data
    def self.dump_csv( klass, attr_type, values_filter, format )
      # TODO: 拡張子は指定してもしなくても良いようにする
      file_name = format[:file] || format[:table]
      dir_name = File.join( Flextures::Config.fixture_dump_directory, format[:dir].to_s )
      FileUtils.mkdir_p(dir_name)
      outfile = File.join(dir_name, "#{file_name}.csv")
      CSV.open(outfile,'w') do |csv|
        # dump column names
        csv<< attr_type.map { |h| h[:name].to_s }
        # dump column datas
        klass.all.each do |row|
          csv<< values_filter.call(row).map(&:last)
        end
      end
      outfile
    end

    # data dump to yaml format
    # @params [Hash] format file format data
    # @params [Hash] options dump format options
    def self.yml( format )
      klass = PARENT::create_model(format[:table])
      attr_type = self.dump_attributes klass, format
      filter = self.create_filter attr_type, format, :yml
      self.dump_yml( klass, filter, format )
    end

    # dump yml format data
    def self.dump_yml( klass, values_filter, format )
      # TODO: 拡張子は指定してもしなくても良いようにする
      table_name = format[:table]
      file_name = format[:file] || format[:table]
      dir_name = File.join( Flextures::Config.fixture_dump_directory, format[:dir].to_s )
      FileUtils.mkdir_p(dir_name)
      outfile = File.join(dir_name, "#{file_name}.yml")
      File.open(outfile,"w") do |f|
        klass.all.each.with_index do |row,idx|
          values = values_filter.call(row).map { |k,v| "  #{k}: #{v}\n" }.join
          f<< "#{table_name}_#{idx}:\n" + values
        end
      end
      outfile
    end
  end
end
