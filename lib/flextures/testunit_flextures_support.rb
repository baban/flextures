# encoding: utf-8

# shouda等へのfixture拡張
module Shoulda
  module Context
    module ClassMethods
      def flextures *_
        context = Shoulda::Context.current_context
        context.setup_blocks<< ->{ Flextures::Loader::flextures *_ }
      end
    end
  end
end

