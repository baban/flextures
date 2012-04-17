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
        #m.after { Flextures::init_tables } if @@configs[:load_count]==0
        @@configs[:load_count] += 1
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
  end
end

module ActiveRecord
  class Fixtures
    def self.create_fixtures(fixtures_directory, table_names, class_names = {})
      table_names = [table_names].flatten.map { |n| n.to_s }
      table_names.each { |n|
        class_names[n.tr('/', '_').to_sym] = n.classify if n.include?('/')
      }

      # FIXME: Apparently JK uses this.
      connection = block_given? ? yield : ActiveRecord::Base.connection

      files_to_read = table_names.reject { |table_name|
	fixture_is_cached?(connection, table_name)
      }

      unless files_to_read.empty?
        connection.disable_referential_integrity do
          fixtures_map = {}

          fixture_files = files_to_read.map do |path|
	    table_name = path.tr '/', '_'

            fixtures_map[path] = ActiveRecord::Fixtures.new(
              connection,
              table_name,
              class_names[table_name.to_sym] || table_name.classify,
              ::File.join(fixtures_directory, path))
          end

          all_loaded_fixtures.update(fixtures_map)

          connection.transaction(:requires_new => true) do
            fixture_files.each do |ff|
              conn = ff.model_class.respond_to?(:connection) ? ff.model_class.connection : connection
              table_rows = ff.table_rows

              table_rows.keys.each do |table|
	        conn.delete "DELETE FROM #{conn.quote_table_name(table)}", 'Fixture Delete'
              end
              p :init_tables
              Flextures::init_tables

              table_rows.each do |table_name,rows|
                rows.each do |row|
                  conn.insert_fixture(row, table_name)
                end
              end
            end

            # Cap primary key sequences to max(pk).
            if connection.respond_to?(:reset_pk_sequence!)
              table_names.each do |table_name|
                connection.reset_pk_sequence!(table_name.tr('/', '_'))
              end
            end
          end

          cache_fixtures(connection, fixtures_map)
	end
      end
      cached_fixtures(connection, table_names)
    end

  end
end

