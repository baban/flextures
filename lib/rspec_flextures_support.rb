# encoding: utf-8

# Rspec��������flextures�ؿ���Ȥ����ͤˤ���
module RSpec
  module Core
    module Hooks
      def flextures *args
        Flextures::Loader::flextures *args
      end
    end
  end
end

