$:.push( File.join(File.dirname(File.expand_path(__FILE__)), '../') )
require 'test_helper'

describe :Extention do
  describe "Array#to_hash" do
    describe "when column size is equal data size" do
      before do
        @keys   = %W[id name hp]
        @values = %W[1 hoge 100]
        @h = @values.extend(Flextures::Extensions::Array).to_hash(@keys)
      end

      it "return hash" do
        assert_equal @h, { "id"=>"1", "name"=>"hoge", "hp"=>"100" }
      end
    end

    describe "when column size is bigger than data size" do
      before do
        @keys   = %W[id name hp]
        @values = %W[1 hoge]
        @h = @values.extend(Flextures::Extensions::Array).to_hash(@keys)
      end

      it "return hash, overflow key is filled 'nil'" do
        assert_equal @h, { "id"=>"1", "name"=>"hoge", "hp"=> nil }
      end
    end

    describe "when column size is smaller than data size" do
      before do
        @keys   = %W[id name]
        @values = %W[1 hoge 200]
        @h = @values.extend(Flextures::Extensions::Array).to_hash(@keys)
      end

      it "return hash, overflow value is cut offed" do
        assert_equal @h, { "id"=>"1", "name"=>"hoge" }
      end
    end
  end
end
