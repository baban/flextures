$:.push( File.join(File.dirname(File.expand_path(__FILE__)), '../') )

require 'test_helper'

describe :Hook do
  describe Flextures::Loader do
    describe ".parse_flextures_options" do
      describe "set one table" do
        before do
          @list = Flextures::Loader.parse_flextures_options({},:users)
        end

        it "return table is Array" do
          assert_equal true, @list.is_a?(Array)
        end

        it "return table is only one" do
          assert_equal 1, @list.size
        end

        it "return data is content Hash data" do
          assert_equal true, @list.first.is_a?(Hash)
        end

        it "return data is contain loading table infomation" do
          h = { table: :users, file: "users", loader: :fun }
          assert_equal h, @list.first
        end
      end

      describe "if set file name option" do
        before do
          @list = Flextures::Loader.parse_flextures_options( {}, :users => :users_another3 )
        end

        it "returned data size is only one" do
          assert_equal 1, @list.size
        end

        it " 'file' option is changed setted file name" do
          assert_equal :users_another3, @list.first[:file]
        end

        it "returned data include data" do
          h = { table: :users, file: :users_another3, loader: :fun }
          assert_equal h, @list.first
        end
      end

      describe "if set 'cache' option" do
        before do
          @list = Flextures::Loader.parse_flextures_options( { cache: true }, :users )
        end

        it "setted cache option" do
          assert_equal true, @list.first[:cache]
        end
      end

      describe " if set 'dir' option " do
        before do
          @list = Flextures::Loader.parse_flextures_options( { dir: "a/b/c" }, :users )
        end

        it "setted cache option" do
          assert_equal "a/b/c", @list.first[:dir]
        end
      end

      describe " if set 'controller' option " do
        before do
          @list = Flextures::Loader.parse_flextures_options( {}, { controller: "top" }, :users )
        end

        it "setted cache option" do
          assert_equal "controllers/top", @list.first[:dir]
        end
      end

      describe " if set 'controller' and 'action' option " do
        before do
          @list = Flextures::Loader.parse_flextures_options( {}, { controller: "top", action:"index" }, :users )
        end

        it "setted cache option" do
          assert_equal "controllers/top/index", @list.first[:dir]
        end
      end

      describe " if set 'model' option " do
        before do
          @list = Flextures::Loader.parse_flextures_options( {}, { model: "users" }, :users )
        end

        it "setted cache option" do
          assert_equal "models/users", @list.first[:dir]
        end
      end

      describe " if set 'model' and 'method' option " do
        before do
          @list = Flextures::Loader.parse_flextures_options( {}, { model: "users", method:"login" }, :users )
        end

        it "setted cache option" do
          assert_equal "models/users/login", @list.first[:dir]
        end
      end
    end
  end
end
