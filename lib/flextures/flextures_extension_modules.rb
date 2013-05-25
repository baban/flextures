# encoding: utf-8

require 'ostruct'

module Flextures
  # Plug-in 内部拡張
  class OpenStruct < ::OpenStruct
    # hashに変化させる
    def to_hash
      (self.methods - ::OpenStruct.new.methods)
        .select{ |name| name.to_s.match(/\w+=/) }
        .map{ |name| name.to_s.gsub(/=/,'').to_sym }
        .inject({}){ |k,h| h[k]=self.send(k); h }
    end
  end

  module Extensions
    module Array
      def to_hash keys
        [keys,self].transpose.inject({}){ |h,pair| k,v=pair; h[k]=v; h }
      end
    end
  end
end


