# base configurations
# if you want to change setting, create 'config/flextures.config.rb', and overwrite setting
#
# example:
# module Flextures
#  # load and dump directroy setting change "spec/fixtures/" to "test/fixtures/"
#  Config.fixture_load_directory = "test/fixtures/"
#  Config.fixture_dump_directory = "test/fixtures/"
# end
#
module Flextures
  module Config
    @@read_onlys = []
    @@configs = {
      use_transactional_fixtures: nil, # override activerecord base "use_transactional_fixtures" option if you  set value boolean value
      ignore_tables: ["schema_migrations"], # 'ignore_tables' table data is not deleted by flextures delete_all method
      fixture_load_directory: "spec/fixtures/", # base load directory
      fixture_dump_directory: "spec/fixtures/", # dump load directory
      init_all_tables: false,  # if this option is 'true', when start unit test, all table data is delete
      options: {}, # options(example { unfilter: true })
      table_load_order: [], # set load options
    }
    # hash key change to getter and setter
    class<< self
      @@configs.each do |setting_key, setting_value|
        define_method(setting_key){ @@configs[setting_key] }
        define_method("#{setting_key}="){ |arg| @@configs[setting_key]=arg } unless @@read_onlys.include?(setting_key)
      end
    end
  end
end
