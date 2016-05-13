require 'ostruct'

module Flextures
  module Extensions
    module Array
      # use Object#extend
      # @params [Array] keys hash keys
      # @return [Hash] tanslated Hash data
      # example:
      # hash = array.extend(Extensions::Array).to_hash(keys)
      def to_hash(keys)
        values = self
        values = values[0..keys.size-1]               if keys.size < values.size
        values = values+[nil]*(keys.size-values.size) if keys.size > values.size
        [keys,values].transpose.reduce({}){ |h,pair| k,v=pair; h[k]=v; h }
      end
    end
  end
end
