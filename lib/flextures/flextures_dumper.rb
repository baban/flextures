# encoding: utf-8

module Flextures
  # データを吐き出す処理をまとめる
  module Dumper
    PARENT = Flextures

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
      file_name = format[:file] || format[:table]
      dir_name = format[:dir] || DUMP_DIR
      outfile = "#{dir_name}#{file_name}.csv"
      table_name = format[:table]
      klass = PARENT.create_model(table_name)
      attributes = klass.columns.map { |colum| colum.name }
      CSV.open(outfile,'w') do |csv|
        csv<< attributes
        klass.all.each do |row|
          csv<< attributes.map { |column| trans(row.send(column)) }
        end
      end
    end

    # yaml で fixtures を dump
    def self.yml format
      file_name = format[:file] || format[:table]
      dir_name = format[:dir] || DUMP_DIR
      outfile = "#{dir_name}#{file_name}.yml"
      table_name = format[:table]
      klass = PARENT::create_model(table_name)
      attributes = klass.columns.map { |colum| colum.name }

      columns = klass.columns
      # テーブルからカラム情報を取り出し
      column_hash = {}
      columns.each { |col| column_hash[col.name] = col }
      # 自動補完が必要なはずのカラム
      lack_columns = columns.select { |c| !c.null and !c.default }.map{ |o| o.name.to_sym }
      not_nullable_columns = columns.select { |c| !c.null }.map &:name

      File.open(outfile,"w") do |f|
        klass.all.each_with_index do |row,idx|
          f<< "#{table_name}_#{idx}:\n" +
            attributes.map { |col|
              v = trans row.send(col)
              v = "|-\n    " + v.gsub(/\n/,%Q{\n    }) if v.kind_of?(String) # Stringだと改行が入るので特殊処理
              "  #{column}: #{v}\n"
            }.join
        end
      end
    end
  end
end

