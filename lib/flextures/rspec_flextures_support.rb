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
        Flextures::init_tables
      end
    end
  end

  RSpec.configure do |c|
    c.include RSpec::Rails::FlextureSupport
  end
end

# 既存のsetup_fixturesの機能を上書きする必要があったのでこちらを作成
module ActiveRecord
  module TestFixtures
    alias :setup_fixtures_bkup :setup_fixtures
    def setup_fixtures
      Flextures::init_load
      setup_fixtures_bkup
    end

    alias :teardown_fixtures_bkup :teardown_fixtures
    def teardown_fixtures
      teardown_fixtures_bkup
    end
  end
end

