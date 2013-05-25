# encoding: utf-8

class FlexturesHookTest < Test::Unit::TestCase
  context Flextures::Loader do
    context ".parse_flextures_options" do
      context "set one table" do
        setup do
          @ret, @options = Flextures::Loader.parse_flextures_options(:users)
        end
        should "return table is only one" do
          assert_equal true, @ret.is_a?(Hash)
        end
        should "return table is only one" do
          assert_equal 1, @ret.size
        end
        should "return data is content Hash data" do
          assert_equal true, @ret.first.is_a?(Hash)
        end
        should "return data is contain loading table infomation" do
          h = { table: :users, file: :users, loader: :fun }
          assert_equal h, @ret.first
        end
      end
      context "if set file name option" do
        setup do
          @ret, @options = Flextures::Loader.parse_flextures_options( :users => :users_another3 )
        end
        should "returned data size is only one" do
          assert_equal 1, @ret.size
        end
        should " 'file' option is changed setted file name" do
          assert_equal :users_another3, @ret.first[:file]
        end
        should "returned data include data" do
          h = { table: :users, file: :users_another3, loader: :fun }
          assert_equal h, @ret.first
        end
      end
      context "if set 'cache' option" do
        setup do
          @ret, @options = Flextures::Loader.parse_flextures_options( { cache: true }, :users )
        end
        should "setted cache option" do
          assert_equal true, @options[:cache]
        end
      end
    end
  end
end

