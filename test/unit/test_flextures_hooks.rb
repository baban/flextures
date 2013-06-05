# encoding: utf-8

class FlexturesHookTest < Test::Unit::TestCase
  context Flextures::Loader do
    context ".parse_flextures_options" do
      context "set one table" do
        setup do
          @list = Flextures::Loader.parse_flextures_options(:users)
        end
        should "return table is Array" do
          assert_equal true, @list.is_a?(Array)
        end
        should "return table is only one" do
          assert_equal 1, @list.size
        end
        should "return data is content Hash data" do
          assert_equal true, @list.first.is_a?(Hash)
        end
        should "return data is contain loading table infomation" do
          h = { table: :users, file: :users, loader: :fun }
          assert_equal h, @list.first
        end
      end
      context "if set file name option" do
        setup do
          @list = Flextures::Loader.parse_flextures_options( :users => :users_another3 )
        end
        should "returned data size is only one" do
          assert_equal 1, @list.size
        end
        should " 'file' option is changed setted file name" do
          assert_equal :users_another3, @list.first[:file]
        end
        should "returned data include data" do
          h = { table: :users, file: :users_another3, loader: :fun }
          assert_equal h, @list.first
        end
      end
      context "if set 'cache' option" do
        setup do
          @list = Flextures::Loader.parse_flextures_options( { cache: true }, :users )
        end
        should "setted cache option" do
          assert_equal true, @list.first[:cache]
        end
      end
      context " if set 'dir' option " do
        setup do
          @list = Flextures::Loader.parse_flextures_options( { dir: "a/b/c" }, :users )
        end
        should "setted cache option" do
          assert_equal "a/b/c", @list.first[:dir]
        end
      end
      context " if set 'controller' option " do
        setup do
          @list = Flextures::Loader.parse_flextures_options( { controller: "top" }, :users )
        end
        should "setted cache option" do
          assert_equal "controllers/top", @list.first[:dir]
        end
      end
      context " if set 'controller' and 'action' option " do
        setup do
          @list = Flextures::Loader.parse_flextures_options( { controller: "top", action:"index" }, :users )
        end
        should "setted cache option" do
          assert_equal "controllers/top/index", @list.first[:dir]
        end
      end
      context " if set 'model' option " do
        setup do
          @list = Flextures::Loader.parse_flextures_options( { model: "users" }, :users )
        end
        should "setted cache option" do
          assert_equal "models/users", @list.first[:dir]
        end
      end
      context " if set 'model' and 'method' option " do
        setup do
          @list = Flextures::Loader.parse_flextures_options( { model: "users", method:"login" }, :users )
        end
        should "setted cache option" do
          assert_equal "models/users/login", @list.first[:dir]
        end
      end
    end
  end
end

