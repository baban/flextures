$:.push( File.join(File.dirname(File.expand_path(__FILE__)), '../') )
require 'test_helper'

describe Flextures do
  it "data type test" do
    assert_equal true, true
  end
end
