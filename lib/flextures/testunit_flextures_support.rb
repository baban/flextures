# encoding: utf-8

# shouda等へのfixture拡張
class Test::Unit::TestCase  
  def self.flextures *_
    setup{ Flextures::Loader::flextures *_ }
  end
end

