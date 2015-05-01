$:.push( File.join(File.dirname(File.expand_path(__FILE__)), '../') )

require 'test_helper'

describe Flextures::ARGS do
  describe "if set TABLE='table_name' option " do
    before do
      ENV["TABLE"] = "users"
      @format = Flextures::ARGS.parse
    end

    it "return table_name" do
      assert_equal "users", @format.first[:table]
    end

    it "filename is same table_name" do
      assert_equal "users", @format.first[:file]
    end

    after do
      ENV.delete("TABLE")
    end
  end

  describe "if set T=table_name option " do
    before do
      ENV["T"] = "s_user"
      @format = Flextures::ARGS.parse
    end

    it "retrun table_name" do
      assert_equal "s_user", @format.first[:table]
    end

    it "filename is same table_name" do
      assert_equal "s_user", @format.first[:file]
    end

    after do
      ENV.delete("T")
    end
  end

  describe " DIR=option " do
    before do
      ENV["T"] = "users"
      ENV["DIR"] = "test/fixtures/"
      @format = Flextures::ARGS.parse
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

    after do
      ENV.delete("T")
      ENV.delete("DIR")
    end
  end

  describe " D=option " do
    before do
      ENV["T"] = "users"
      ENV["D"] = "test/fixtures/"
      @format = Flextures::ARGS.parse
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

    after do
      ENV.delete("T")
      ENV.delete("D")
    end
  end

  describe " FIXTURES=option " do
    before do
      ENV["T"] = "users"
      ENV["FIXTURES"] = "user_another"
      @format = Flextures::ARGS.parse
    end

    it "table name is exist" do
      assert_equal "users", @format.first[:table]
    end

    it " file name is changed by option's name " do
      assert_equal "user_another", @format.first[:file]
    end

    after do
      ENV.delete("T")
      ENV.delete("FIXTURES")
    end
  end

  describe " MINUS option " do
    describe "only one columns" do
      before do
        ENV["T"]="users"
        ENV["MINUS"]="id"
        @format = Flextures::ARGS.parse
      end

      it " option contain 'minus' parameters" do
        assert_equal ["id"], @format.first[:minus]
      end
    end

    describe "many columns" do
      before do
        ENV["T"]="users"
        ENV["MINUS"]="id,created_at,updated_at"
        @format = Flextures::ARGS.parse
      end

      it " option contain 'minus' parameters" do
        assert_equal ["id","created_at","updated_at"], @format.first[:minus]
      end
    end

    after do
      ENV.delete("T")
      ENV.delete("MINUS")
    end
  end

  describe " PLUS options " do
    before do
      ENV["T"]="users"
    end

    describe "only one columns" do
      before do
        ENV["PLUS"]="hoge"
        @format = Flextures::ARGS.parse
      end

      it " option contain 'plus' parameters" do
        assert_equal ["hoge"], @format.first[:plus]
      end
    end

    describe "many columns" do
      before do
        ENV["PLUS"]="hoge,mage"
        @format = Flextures::ARGS.parse
      end

      it " option contain 'plus' parameters" do
        assert_equal ["hoge","mage"], @format.first[:plus]
      end
    end

    after do
      ENV.delete("T")
      ENV.delete("PLUS")
    end
  end
end
