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
