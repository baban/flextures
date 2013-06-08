# encoding: utf-8

# flxtures function shouda support
module Shoulda
  module Context
    module ClassMethods
      def flextures *_
        context = Shoulda::Context.current_context
        context.setup_blocks<< ->{ Flextures::Loader::flextures *_ }
      end
      # TODO : 実装
      def flextures_delete
      end
      # TODO : 実装
      def flextures_set_config
      end
      # TODO : 実装
      def flextures_options
      end
    end
  end
end

