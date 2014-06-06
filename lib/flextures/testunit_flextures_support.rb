# encoding: utf-8

# flxtures function shouda support
module Shoulda
  module Context
    module ClassMethods
      def flextures( *_ )
        context = Shoulda::Context.current_context
        context.setup_blocks<< ->{ Flextures::Loader::flextures *_ }
      end

      def flextures_delete( *_ )
        context = Shoulda::Context.current_context
        context.setup_blocks<< -> {
          if _.empty?
            Flextures::init_tables
          else
            Flextures::delete_tables *_
          end
        }
      end

      def flextures_set_options( options={} )
        context = Shoulda::Context.current_context
        context.setup_blocks<< -> {
          Flextures::Loader::set_options options
        }
        context.teardown_blocks<< -> {
          Flextures::Loader::delete_options
        }
      end
    end
  end
end
