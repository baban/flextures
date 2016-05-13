# base configurations
module Flextures
  class Configuration
    include ActiveSupport::Configurable

    config_accessor :ignore_tables do
      ["schema_migrations"]
    end

    config_accessor :load_directory do
      "spec/fixtures/"
    end

    config_accessor :dump_directory do
      "spec/fixtures/"
    end

    config_accessor :init_all_tables do
      true
    end
  end
end
