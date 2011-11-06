# encoding: utf-8

module Flextures
  # ロードするデータを必要に応じて加工する
  class Factory
    FACTORIES={}
    # Factory を定義
    def self.define table_name, &block
      FACTORIES[table_name.to_sym]=block
    end

    # Factoryを取得
    def self.get table_name
      FACTORIES[table_name.to_sym]
    end
    def self.[](table_name); self.get(table_name); end
  end
end

