# encoding: utf-8

# Rspecの内部でflextures関数を使える様にする
module RSpec
  module Core
    module Hooks
      # 引数で渡されたファイルを読み込みする
      def flextures *_
        before { Flextures::Loader::flextures *_ }
      end

      # 引数で渡されたテーブルのデータをdeleteする
      def flextures_delete
        before { Flextures::init_tables }
      end

      def flextures_set_config
        # TODO: ハッシュで渡された設定をセットする
      end
    end
  end

  module Rails
    module FlextureSupport
      def self.included(m)
        # 実行前にテーブルの初期化
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

