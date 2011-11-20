# encoding: utf-8

# shouda等へのfixture拡張
class Test::Unit::TestCase  
  def self.flextures *args
    setup{ Flextures::Loader::flextures *args }
  end
end

