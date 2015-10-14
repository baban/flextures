module RSpec
  module Rails
    module SetupAndTeardownAdapter
      extend ActiveSupport::Concern

      module ClassMethods
        def flextures_prepend_before(&block)
          prepend_before(&block)
        end

        def flextures_before(&block)
          before(&block)
        end
      end
    end
  end
end

# flextures function use like fixtures method in RSpec
module RSpec
  module Core
    module Hooks
      # flexturesの読み出し
      def create_or_get_flextures_loader(*_)
        @@flextures_loader ||= Flextures::Loader.new(*_)
      end

      def flextures_get_options
        @@flextures_loader
      end

      # delete table data
      # @params [Array] _ table names
      def flextures_delete( *_ )
        flextures_loader = create_or_get_flextures_loader(__method__)
        flextures_before do
          if _.empty?
            Flextures::init_tables
          else
            Flextures::delete_tables( *_ )
          end
        end
      end

      def flextures_set_options( options )
        flextures_loader = create_or_get_flextures_loader(__method__)
        flextures_prepend_before do
          flextures_loader.set_options( options )
        end
      end
    end
  end

  module Rails
    module FlextureSupport
      def self.included(m)
        Flextures::init_tables
      end
    end
  end

  RSpec.configure do |c|
    c.include RSpec::Rails::FlextureSupport
  end
end

# override setup_fixtures function
module ActiveRecord
  module TestFixtures
    @@already_loaded_flextures = {}

    alias :setup_fixtures_bkup :setup_fixtures
    def setup_fixtures
      Flextures::load_configurations
      setup_fixtures_bkup
      set_transactional_filter_params
    end

    # nilで無い時は値をtransactional_filterが有効　
    def set_transactional_filter_params
      return if Flextures::Config.use_transactional_fixtures.nil?
      self.use_transactional_fixtures = Flextures::Config.use_transactional_fixtures
    end

    alias :teardown_fixtures_bkup :teardown_fixtures
    def teardown_fixtures
      teardown_fixtures_bkup
    end

    # DBに既に同じデータが読み込まれているかをチェックする
    def cached_table?(load_setting)
      # 読み込んだテーブルのデータをチェック、中身のフォーマットとパスが既に読まれたものと同じなら、保存する。
      config = @@already_loaded_flextures[self.class].to_a.select{ |setting| setting[:table]==load_setting[:table] }.first
      if config && config == load_setting
        return true
      end

      # fixture関数で読み込んだものも有効活用する
      if load_setting[:file] == "spec/fixture/#{load_setting[:table]}.yml" && yml_fixture_cached?(load_setting[:table])
        return true
      end

      false
    end

    # 同じ文脈で既にキャッシュを持ったことがあるかを判別する
    def cached_context?
      !!@@already_loaded_flextures[self.class]
    end

    # この文脈は一度キャッシュを終えたデータであることを明示する
    def set_flextures_cache!(table_load_settings)
      @@already_loaded_flextures[self.class] ||= []
      @@already_loaded_flextures[self.class] += table_load_settings
      @@already_loaded_flextures[self.class].uniq
    end

    def all_cached_flextures
      @@already_loaded_flextures[self.class]
    end

    def uncached_flextures
      @@already_loaded_flextures[self.class].reject { |setting| setting[:cache] }
    end

    def yml_fixture_cached?(table_name)
      connection = ActiveRecord::Base.connection
      !!ActiveRecord::FixtureSet.fixture_is_cached?(connection, table_name)
    end

    module ClassMethods
      @@instance = Flextures::Loader.new

      def flextures(*fixtures)
        table_load_settings = Flextures::Loader.parse_flextures_options({}, *fixtures)

        before do
          # 文脈ごとにキャッシュが決まっている
          # TODO: @flextures_called_checkerは変数の領域を汚すので、使わなくて良い方法を考えておく
          if cached_context? and @flextures_called_checker != true
            @flextures_called_checker = true
            # 同じ文脈で最初にflexturesが読み込まれた場合に再読み込みを行う
            # キャッシュを回避したfixtureだけが読み込まれる
            uncached_flextures.each do |load_setting|
              @@instance.load(load_setting)
            end
          else
            table_load_settings.each do |load_setting|
              if cached_table?(load_setting) and load_setting[:cache] != false
                next
              end
              @@instance.load(load_setting)
            end
          end
        end

        after do
          set_flextures_cache!(table_load_settings)
          # キャッシュにデータを保存
        end

        # 1.読み込みべきテーブルとデータを決める
        # 2.キャッシュを参照してキャッシュと一致しているものは読み込みは行わない
        # 3.データの読み込み
        # 4.トランザクションを貼る
        # 5.テストを実行
        # 6.トランザクションを解除
        #
        # if cached?(table_name, format, path)
        #
        # else
        #  load(table_name, format, path)
        # end
        #
        # =>  do_transaction
        #
        # キャッシュをチェック
      end

    end
  end
end
