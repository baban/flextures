# encoding: utf-8

# flextures function use like fixtures method in RSpec
module RSpec
  module Core
    module Hooks
      # load fixtture data
      # @params [Array] _ fixture file names
      def flextures( *_ )
        @flextures_loader ||= Flextures::Loader::Instance.new
        flextures_loader = @flextures_loader
        before do
          flextures_loader.loads( *_ )
          #Flextures::Loader.flextures( *_ )
        end
      end

      # delete table data
      # @params [Array] _ table names
      def flextures_delete( *_ )
        before do
          if _.empty?
            Flextures::init_tables
          else
            Flextures::delete_tables( *_ )
          end
        end
      end

      def flextures_set_options( options )
        before do
          Flextures::Loader::set_options( options )
        end

        after do
          Flextures::Loader::delete_options
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
