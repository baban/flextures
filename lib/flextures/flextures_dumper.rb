# encoding: utf-8

require "fileutils"

module Flextures
  # データを吐き出す処理をまとめる
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
            is_nl |= ["[","]","{","}","|","#","@","~","!","'","$","&","^","<",">","?","-","+","=",";",":",".",",","*","`","(",")"].member? s[0]
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
      procs = rules.inject(proc{ |d| d }) { |sum,i| sum * (rule_map[i] || i)  }
      procs.call(val)
    end

    TRANSLATER = {
      binary:->( d, format ){
        procs = (format == :yml)?
          [:nullstr, :null, proc { |d| Base64.encode64(d) } ] :
          [:null, proc { |d| Base64.encode64(d) } ]
        self.translate_creater d, procs
      },
      boolean:->( d, format ){
        procs = (format == :yml) ?
          [ :nullstr, proc { !(0==d || ""==d || !d) } ] :
          [ proc { !(0==d || ""==d || !d) } ]
        self.translate_creater d, procs
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
    }

    # 適切な型に変換
    def self.trans( v, type, format )
      trans = TRANSLATER[type]
      return trans.call( v, format ) if trans
      v
    end

    # csv で fixtures を dump
    def self.csv format, options={}
      # TODO: 拡張子は指定してもしなくても良いようにする
      file_name = format[:file] || format[:table]
      dir_name = format[:dir] || Flextures::Config.fixture_dump_directory
      outfile = File.join(dir_name, "#{file_name}.csv")
      table_name = format[:table]
      klass = PARENT.create_model(table_name)
      attributes = klass.columns.map &:name
      filter = DumpFilter[table_name] || {}

      attr_type = klass.columns.map { |column| { name: column.name, type: column.type } }
      # 出力したくないカラムを削除
      attr_type.reject! { |v| options[:minus].include?(v) } if options[:minus]
      values_filter =->(row) {
        attr_type.map do |h|
          filter[h[:name].to_sym] ? filter[h[:name].to_sym].call(row[h[:name]]) : trans(row[h[:name]], h[:type], :csv)
        end
      }

      header = attributes + options[:plus].to_a
      # outfile, dir_name, header, klass
      CSV.open(outfile,'w') do |csv|
        # 指定されたディレクトリを作成
        FileUtils.mkdir_p(dir_name)
        # dump column names
        csv<< header
        klass.all.each do |row|
          csv<< values_filter.call(row)
        end
      end
      outfile
    end

    # yaml で fixtures を dump
    def self.yml format, options={}
      # TODO: 拡張子は指定してもしなくても良いようにする
      file_name = format[:file] || format[:table]
      dir_name = format[:dir] || Flextures::Config.fixture_dump_directory
      outfile = File.join(dir_name, "#{file_name}.yml")
      table_name = format[:table]
      klass = PARENT::create_model(table_name)
      attributes = klass.columns.map &:name
      columns = klass.columns
      # テーブルからカラム情報を取り出し
      column_hash = columns.inject({}) { |h,col| h[col.name] = col; h }
      # 自動補完が必要なはずのカラム
      lack_columns = columns.reject { |c| c.null or c.default }.map{ |o| o.name.to_sym }
      not_nullable_columns = columns.reject(&:null).map &:name

      filter = DumpFilter[table_name] || {}
      # 追加のカラムを指定
      plus = options[:plus].to_a.map { |colname| "  #{colname}: null\n" }
      columns = klass.columns
      columns.reject! { |v| options[:minus].include?(v) } if options[:minus]
      File.open(outfile,"w") do |f|
        # 指定されたディレクトリを作成
        FileUtils.mkdir_p(dir_name)
        klass.all.each.with_index do |row,idx|
          values = columns.map { |column|
            colname, coltype = column.name.to_sym, column.type
            v = filter[colname] ? filter[colname].call(row[colname]) : trans(row[colname], coltype, :yml)
            "  #{colname}: #{v}\n"
          } + plus
          f<< "#{table_name}_#{idx}:\n" + values*""
        end
      end
      outfile
    end
  end
end

