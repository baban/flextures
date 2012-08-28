# encoding: utf-8

class FlexturesDumperTest < Test::Unit::TestCase
  should "データの型が一致" do
    assert_equal Module, Flextures::Dumper.class
  end
end

