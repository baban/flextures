# encoding: utf-8

# Rspecの内部でflextures関数を使える様にする
module RSpec
  module Core
    module Hooks
      def flextures *_
        before { Flextures::Loader::flextures *_ }
      end
    end
  end

  module Rails
    module FlextureSupport
      @@configs={ load_count: 0 }
      def self.included(m)
        # 一番外側のdescribeにだけ追加
        m.before { Flextures::init_load } if @@configs[:load_count]==0
        @@configs[:load_count] += 1
      end
    end
  end

  RSpec.configure do |c|
    c.include RSpec::Rails::FlextureSupport
  end
end

