
module Flextures
  class Railtie < Rails::Railtie
    rake_tasks do
      load "flextures/flextures.rake"
    end
  end
end
