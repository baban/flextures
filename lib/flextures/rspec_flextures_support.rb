# flextures function use like fixtures method in RSpec
module RSpec
  module Rails
    module FlextureSupport
      @@once_included = false
      def self.included(m)
        init_tables
      end

      def self.init_tables
        unless @@once_included
          Flextures::init_tables
          @@once_included = true
        end
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
    PARENT = self
    @@flextures_loader = Flextures::Loader.new
    @@all_cached_flextures = {}
    @@already_loaded_flextures = {}

    alias :setup_fixtures_bkup :setup_fixtures
    def setup_fixtures
      Flextures::load_configurations
      setup_fixtures_bkup
    end

    alias :teardown_fixtures_bkup :teardown_fixtures
    def teardown_fixtures
      teardown_fixtures_bkup
    end

    # 最初にデフォルトのデータをキャッシュする
    def self.init_load_should_cache_fixtures(table_load_settings)
      table_load_settings.each do |load_setting|
        if should_cache_setting?(load_setting) and !cached_table?(load_setting)
          @@flextures_loader.load(load_setting)
          cache_table(load_setting)
        end
      end
    end

    # キャッシュされるべきfixtureかどうかを判別する
    def self.should_cache_setting?(load_setting)
      load_setting.keys.sort == %i[table file loader].sort &&
      load_setting[:file].to_s == load_setting[:table].to_s &&
      load_setting[:loader] == :fun
    end

    # DBに既に同じデータが読み込まれているかをチェックする
    def self.cached_table?(load_setting)
      # * キャッシュされていないデータはパスが、デフォルトと異なっている
      # * キャッシュがfalseになっている
      flextures_cached?(load_setting) || fixture_cached?(load_setting)
    end

    # 読み込んだテーブルのデータをチェック、中身のフォーマットとパスが既に読まれたものと同じなら、保存する。
    def self.flextures_cached?(load_setting)
      # cached[yml/csv] file is
      config = @@all_cached_flextures[load_setting[:table]]
      config && config == load_setting
    end

    # fixture関数で読み込んだものも有効活用する
    def self.fixture_cached?(load_setting)
      default_file_path = File.join(Flextures::Config.fixture_load_directory, "#{load_setting[:table]}.yml")

      load_setting[:file] == default_file_path &&
      yml_fixture_cached?(load_setting[:table])
    end

    def self.yml_fixture_cached?(table_name)
      connection = ActiveRecord::Base.connection
      !!ActiveRecord::FixtureSet.fixture_is_cached?(connection, table_name)
    end

    def self.cache_table(load_setting)
      @@all_cached_flextures[load_setting[:table]] = load_setting
    end

    # キャッシュされていないデータを読み出す
    def load_not_cached_fixtures(table_load_settings)
      table_load_settings.each do |load_setting|
        if PARENT.cached_table?(load_setting) and load_setting[:cache] != false
          next
        else
          @@flextures_loader.load(load_setting)
        end
      end
    end

    module ClassMethods
      def flextures_loader
        PARENT.class_variable_get(:@@flextures_loader)
      end

      def flextures(*fixtures)
        table_load_settings = Flextures::Loader.parse_flextures_options({}, *fixtures)

        PARENT.init_load_should_cache_fixtures(table_load_settings)

        before do
          load_not_cached_fixtures(table_load_settings)
        end
      end

      # delete table data
      # @params [Array] _ table names
      def flextures_delete(*_)
        before do
          if _.empty?
            Flextures::init_tables
          else
            Flextures::delete_tables(*_)
          end
        end
      end

      def flextures_set_options(options)
        prepend_before do
          flextures_loader.set_options(options)
        end
      end
    end
  end
end
