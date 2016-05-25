module Flextures
  module Generators
    class InitializerGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def create_initializer_file
        copy_file "flextures.rb", "config/initializers/flextures.rb"
        copy_file "flextures.factory.rb", "config/flextures.factory.rb"
      end

      desc <<-MSG
Description:
  Creates flextures configuration files.
      MSG
    end
  end
end
