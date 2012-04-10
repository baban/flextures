# encoding: utf-8

module Flextures
  # データを吐き出す処理をまとめる
  module Dumper
    PARENT = Flextures

    TRANSLATER = {
      binary:->(d, format = :csv){
        d.to_i
      },
      boolean:->(d, format = :csv){
        (0==d || ""==d || !d) ? false : true
      },
      date:->(d, format = :csv){
        Date.parse(d.to_s)
      },
      datetime:->(d, format = :csv){
        DateTime.parse(d.to_s)
      },
      decimal:->(d, format = :csv){
        d.to_i
      },
      float:->(d, format = :csv){
        d.to_f
      },
      integer:->(d, format = :csv){
        d.to_i
      },
      string:->(s, format = :csv){
        s = "|-\n    " + s.gsub(/\n/,%Q{\n    }) if format == :yml and s["\n"] # 改行付きはフォーマット変更
        s = s.gsub(/\t/,"  ")                    if format == :yml and s["\t"] # tabは空白スペース２つ
        s
      },
      text:->(s, format = :csv){
        s = "|-\n    " + s.gsub(/\n/,%Q{\n    }) if format == :yml and s["\n"] # 改行付きはフォーマット変更
        s = s.gsub(/\t/,"  ")                    if format == :yml and s["\t"] # tabは空白スペース２つ
        s
      },
      time:->(d, format = :csv){
        DateTime.parse(d.to_s)
      },
      timestamp:->(d, format = :csv){
        DateTime.parse(d.to_s)
      },
    }

    # 適切な型に変換
    def self.trans v, format = :csv
      type = nil
      type = :string  if v.is_a?(String)
      type = :boolean if (v == true or v == false)
      trans = TRANSLATER[type]
      return trans.call( v, format ) if trans
      v
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
              v = trans row.send(col), :yml
              "  #{col}: #{v}\n"
            }.join
        end
      end
    end
  end
end

