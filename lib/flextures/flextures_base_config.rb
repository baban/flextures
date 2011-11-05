# encoding: utf-8

# ��{�ݒ���L�q����
module Flextures
  module Config
    @@configs={
      fixture_load_directory: "spec/fixtures/",
      fixture_dump_directory: "spec/fixtures/",
    }
    # �n�b�V����setter�Agetter�ɕϊ�
    class<< self
      @@configs.each do |setting_key, setting_value|
        define_method setting_key do @@configs[setting_key] end
        define_method "#{setting_key}=" do |arg| @@configs[setting_key]=arg end
      end
    end
  end
end


