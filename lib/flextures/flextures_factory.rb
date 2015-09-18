module Flextures
  # Flextures FactoryFilter is program to translate ActiveRecord data
  class LoadFilter
    # FactoryFilter data
    FACTORIES={}

    # set FactoryFilter
    # @params [String] table_name
    # @params [Array] options arguments ActiveRecord Model
    # @params [Proc] block FactoryFilter
    def self.define( table_name, *options, &block )
      h={ block: block }
      options.each do |o|
        begin
          h[:model] = o if o.new.is_a?(ActiveRecord::Base)
        rescue
        end
      end
      FACTORIES[table_name.to_sym]=h
    end

    # get FactoryFilter
    # @params [String|Symbol] table_name
    # @return [Proc] filter block
    def self.get( table_name )
      f = FACTORIES[table_name.to_sym]
      f && f[:block]
    end
    def self.[](table_name); self.get(table_name); end
  end

  class DumpFilter
    # FactoryDumpFilter data
    FACTORIES={}

    # set FactoryFilter
    # @params table_name
    # @params options
    # @params block
    # @return Flextures::Factory
    def self.define( table_name, hash )
      FACTORIES[table_name.to_sym]=hash
    end

    # get FactoryFilter
    def self.get( table_name )
      FACTORIES[table_name.to_sym]
    end
    def self.[](table_name); self.get(table_name); end
  end
  Factory = LoadFilter
end
