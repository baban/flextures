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
        Time.parse(d.to_s).to_s
      },
      datetime:->(d, format = :csv){
        Time.parse(d.to_s).to_s
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
        if format == :yml
          return "null"                          if s.nil?
          s = s.gsub(/\t/,"  ")                  if s["\t"]   # tabは空白スペース２つ
          s = s.sub(/ +/, "")                    if s[0]==' ' # 先頭のスペースは削除
          s = "|-\n    " + s.gsub(/\n/,"\n    ") if s["\n"]   # 改行付きはフォーマット変更
        end
        s
      },
      text:->(s, format = :csv){
        if format == :yml
          return "null"                          if s.nil?
          s = s.gsub(/\t/,"  ")                  if s["\t"]
          s = s.sub(/ +/, "")                    if s[0]==' '
          s = "|-\n    " + s.gsub(/\n/,"\n    ") if s["\n"]
        end
        s
      },
      time:->(d, format = :csv){
        Time.parse(d.to_s).to_s
      },
      timestamp:->(d, format = :csv){
        Time.parse(d.to_s).to_s
      },
    }

    # 適切な型に変換
    def self.trans(v, type, format)
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
      attributes = klass.columns.map { |column| column.name }
      CSV.open(outfile,'w') do |csv|
        attr_type = klass.columns.map { |column| { name: column.name, type: column.type } }
        csv<< attributes
        klass.all.each do |row|
          csv<< attr_type.map { |h| trans(row[h[:name]], h[:type], :csv) }
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
            klass.columns.map { |column|
              colname, coltype = column.name, column.type
              v = trans(row[colname], coltype, :yml)
              "  #{colname}: #{v}\n"
            }.join
        end
      end
    end
  end
end

