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

    # load initial fixtures
    # There is fixtures load before start rspec
    def self.init_load_should_cache_fixtures(table_load_settings)
      table_load_settings.each do |load_setting|
        if should_cache_setting?(load_setting) and !cached_table?(load_setting)
          @@flextures_loader.load(load_setting)
          set_cached_settng_list(load_setting)
        end
      end
    end

    # Usually, fixture is cached when is exist under "spec/fixture/" directly.
    def self.should_cache_setting?(load_setting)
      load_setting.keys.sort == %i[table file loader].sort &&
      load_setting[:file].to_s == load_setting[:table].to_s &&
      load_setting[:loader] == :fun
    end

    # check: same data is exist in DB.
    def self.cached_table?(load_setting)
      flextures_cached?(load_setting) || fixture_cached?(load_setting)
    end

    def self.flextures_cached?(load_setting)
      config = @@all_cached_flextures[load_setting[:table]]
      config && config == load_setting
    end

    # flextures check fixture function already loaded data.
    def self.fixture_cached?(load_setting)
      default_file_path = File.join(Flextures::Config.fixture_load_directory, "#{load_setting[:table]}.yml")

      load_setting[:file] == default_file_path &&
      yml_fixture_cached?(load_setting[:table])
    end

    def self.yml_fixture_cached?(table_name)
      connection = ActiveRecord::Base.connection
      !!ActiveRecord::FixtureSet.fixture_is_cached?(connection, table_name)
    end

    def self.set_cached_settng_list(load_setting)
      @@all_cached_flextures[load_setting[:table]] = load_setting
    end

    def load_not_cached_fixtures(table_load_settings)
      table_load_settings.each do |load_setting|
        if PARENT.cached_table?(load_setting) and load_setting[:cache] != false
          next
        else
          @@flextures_loader.load(load_setting)
        end
      end
    end

    def load_all_fixtures(table_load_settings)
      table_load_settings.each do |load_setting|
        @@flextures_loader.load(load_setting)
      end
    end

    module ClassMethods
      def get_or_initialize_flextures_loader_options
        @flextures_loader_options ||= {}
      end

      def flextures_loader_options
        get_or_initialize_flextures_loader_options
      end

      def flextures_loader
        PARENT.class_variable_get(:@@flextures_loader)
      end

      def flextures(*fixtures)
        loads_use_cache_fixtures(*fixtures)
      end

      def loads_use_cache_fixtures(*fixtures)
        table_load_settings = Flextures::Loader.parse_flextures_options(flextures_loader_options, *fixtures)

        if use_transactional_fixtures
          PARENT.init_load_should_cache_fixtures(table_load_settings)
          before do
            load_not_cached_fixtures(table_load_settings)
          end
        else
          before do
            load_all_fixtures(table_load_settings)
          end
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
        @flextures_loader_options = get_or_initialize_flextures_loader_options
        @flextures_loader_options = @flextures_loader_options.merge(options)
      end
    end
  end
end
