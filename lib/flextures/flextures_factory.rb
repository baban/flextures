# encoding: utf-8

module Flextures
  # ���ɤ���ǡ�����ɬ�פ˱����Ʋù�����
  class Factory
    FACTORIES={}
    # Factory �����
    def self.define table_name, &block
      FACTORIES[table_name.to_sym]=block
    end

    # Factory�����
    def self.get table_name
      FACTORIES[table_name.to_sym]
    end
    def self.[](table_name); self.get(table_name); end
  end
end

