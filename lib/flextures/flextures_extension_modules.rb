# encoding: utf-8

require 'ostruct'

module Flextures
  # Plug-in 内部拡張
  class OpenStruct < ::OpenStruct
    # hashに変化させる
    def to_hash
      h={}
      (self.methods - ::OpenStruct.new.methods)
        .select{ |name| name.to_s.match(/\w+=/) }
        .map{ |name| name.to_s.gsub(/=/,'').to_sym }
        .each{ |k| h[k]=self.send(k) }
      h
    end
  end

  module Extensions
    module Array
      def to_hash keys
        h = {}
        [keys,self].transpose.each{ |k,v| h[k]=v }
        h
      end
    end
  end
end


