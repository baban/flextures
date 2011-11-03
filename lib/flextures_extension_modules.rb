# encoding: utf-8

module Flextures
  # Plug-in �����g��
  class OpenStruct < ::OpenStruct
    # hash�ɕω�������
    def to_hash
      h={}
      (self.methods - OpenStruct.new.methods)
        .select{ |name| name.match(/\w+=/) }
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


