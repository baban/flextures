# encoding: utf-8

module Flextures
  # ロードするデータを必要に応じて加工する
  class LoadFilter
    # 設置ファイルから取得した Factoryの一覧を取得
    FACTORIES={}

    # Factory を定義
    # @params table_name
    # @params options
    # @params block
    # @return Flextures::Factory
    def self.define table_name, *options, &block
      h={ block: block }
      options.each do |o|
        begin
          h[:model] = o if o.new.is_a? ActiveRecord::Base
        rescue
        end
      end
      FACTORIES[table_name.to_sym]=h
    end

    # Factoryを取得
    def self.get table_name
      f = FACTORIES[table_name.to_sym]
      f && f[:block]
    end
    def self.[](table_name); self.get(table_name); end
  end
  class DumpFilter
    
  end
  Factory = LoadFilter
end

