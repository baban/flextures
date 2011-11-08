# encoding: utf-8

# shouda等へのfixture拡張
module Test::Unit::TestCase  
  def flextures *args
    before{ Flextures::Loader::flextures *args }
  end
end

