$:.push( File.join(File.dirname(File.expand_path(__FILE__)), '../') )

require 'test_helper'

describe Flextures::ARGS do
  describe "if set TABLE='table_name' option " do
    before do
      @format = Flextures::ARGS.parse("TABLE"=>"users")
    end

    it "return table_name" do
      assert_equal "users", @format.first[:table]
    end

    it "filename is same table_name" do
      assert_equal "users", @format.first[:file]
    end
  end

  describe "if set T=table_name option " do
    before do
      @format = Flextures::ARGS.parse("T"=>"s_user")
    end

    it "retrun table_name" do
      assert_equal "s_user", @format.first[:table]
    end

    it "filename is same table_name" do
      assert_equal "s_user", @format.first[:file]
    end
  end

  describe " DIR=option " do
    before do
      @format = Flextures::ARGS.parse("T"=>"users", "DIR"=>"test/fixtures/")
    end

    it "directory name is exist" do
      assert_equal "test/fixtures/", @format.first[:dir]
    end

    it "set table name" do
      assert_equal "users", @format.first[:table]
    end

    it "file name is equal table name" do
      assert_equal "users", @format.first[:file]
    end
  end

  describe " D=option " do
    before do
      @format = Flextures::ARGS.parse("T"=>"users", "D"=>"test/fixtures/")
    end

    it "directory name" do
      assert_equal "test/fixtures/", @format.first[:dir]
    end

    it "table name is exist" do
      assert_equal "users", @format.first[:table]
    end

    it "file name is equal table name" do
      assert_equal "users", @format.first[:file]
    end
  end

  describe " FIXTURES=option " do
    before do
      @format = Flextures::ARGS.parse("T"=>"users", "FIXTURES"=>"user_another")
    end

    it "table name is exist" do
      assert_equal "users", @format.first[:table]
    end

    it " file name is changed by option's name " do
      assert_equal "user_another", @format.first[:file]
    end
  end

  describe " MINUS option " do
    describe "only one columns" do
      before do
        @format = Flextures::ARGS.parse("T"=>"users", "MINUS"=>"id")
      end

      it " option contain 'minus' parameters" do
        assert_equal ["id"], @format.first[:minus]
      end
    end

    describe "many columns" do
      before do
        @format = Flextures::ARGS.parse("T"=>"users", "MINUS"=>"id,created_at,updated_at")
      end

      it " option contain 'minus' parameters" do
        assert_equal ["id","created_at","updated_at"], @format.first[:minus]
      end
    end
  end

  describe " PLUS options " do
    describe "only one columns" do
      before do
        @format = Flextures::ARGS.parse("T"=>"users", "PLUS"=>"hoge")
      end

      it " option contain 'plus' parameters" do
        assert_equal ["hoge"], @format.first[:plus]
      end
    end

    describe "many columns" do
      before do
        @format = Flextures::ARGS.parse("T"=>"users", "PLUS"=>"hoge,mage")
      end

      it " option contain 'plus' parameters" do
        assert_equal ["hoge","mage"], @format.first[:plus]
      end
    end
  end
end
