# encoding: utf-8

class FlexturesTest < Test::Unit::TestCase
  should "データの型が一致" do
    assert_equal Module, Flextures.class
  end
end

