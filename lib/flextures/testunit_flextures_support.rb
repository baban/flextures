# encoding: utf-8

# flxtures function shouda support
module Shoulda
  module Context
    module ClassMethods
      def create_or_get_flextures_loader
        @flextures_loader ||= Flextures::Loader::Instance.new
      end

      def flextures( *_ )
        flextures_loader = create_or_get_flextures_loader

        context = Shoulda::Context.current_context
        context.setup_blocks<< ->{ flextures_loader.flextures(*_) }
      end

      def flextures_delete( *_ )
        context = Shoulda::Context.current_context

        context.setup_blocks<< -> {
          if _.empty?
            Flextures::init_tables
          else
            Flextures::delete_tables(*_)
          end
        }
      end

      def flextures_set_options( options={} )
        flextures_loader = create_or_get_flextures_loader

        context = Shoulda::Context.current_context
        context.setup_blocks<< -> {
          flextures_loader.set_options(options)
        }
        context.teardown_blocks<< -> {
          flextures_loader.delete_options
        }
      end
    end
  end
end
