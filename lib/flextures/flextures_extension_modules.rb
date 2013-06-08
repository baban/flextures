# encoding: utf-8

require 'ostruct'

module Flextures
  # OpenStruct hack in flextures Plug-in
  class OpenStruct < ::OpenStruct
    # Struct Data translate to Hash
    def to_hash
      (self.methods - ::OpenStruct.new.methods)
        .select{ |name| name.to_s.match(/\w+=/) }
        .map{ |name| name.to_s.gsub(/=/,'').to_sym }
        .inject({}){ |k,h| h[k]=self.send(k); h }
    end
  end

  module Extensions
    module Array
      # use Object#extend
      # @params [Array] keys hash keys
      # @return [Hash] tanslated Hash data
      # example:
      # hash = array.extend(Extensions::Array).to_hash(keys)
      def to_hash keys
        [keys,self].transpose.inject({}){ |h,pair| k,v=pair; h[k]=v; h }
      end
    end
  end
end


