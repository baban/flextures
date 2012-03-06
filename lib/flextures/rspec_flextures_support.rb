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
end

# 既存のsetup_fixturesの機能を上書きする必要があったのでこちらを作成
module ActiveRecord
  module TestFixtures
    alias :flextures_backup_setup_fixtures :setup_fixtures
    def setup_fixtures
      flextures_backup_setup_fixtures
      Flextures::init_load
    end

    alias :flextures_backup_teardown_fixtures :teardown_fixtures
    def teardown_fixtures
      Flextures::init_tables if Flextures::Config.init_all_tables
      flextures_backup_teardown_fixtures
    end
  end
end

