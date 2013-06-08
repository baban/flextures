# encoding: utf-8

class FlexturesArgsTest < Test::Unit::TestCase
  context Flextures::ARGS do
    context "if set TABLE='table_name' option " do
      setup do
        ENV["TABLE"] = "users"
        @format = Flextures::ARGS.parse
      end
      should "return table_name" do
        assert_equal "users", @format.first[:table]
      end
      should "filename is same table_name" do
        assert_equal "users", @format.first[:file]
      end
      teardown do
        ENV.delete("TABLE")
      end
    end
    context "if set T=table_name option " do
      setup do
        ENV["T"] = "s_user"
        @format = Flextures::ARGS.parse
      end
      should "retrun table_name" do
        assert_equal "s_user", @format.first[:table]
      end
      should "filename is same table_name" do
        assert_equal "s_user", @format.first[:file]
      end
      teardown do
        ENV.delete("T")
      end
    end
    context " DIR=option " do
      setup do
        ENV["T"] = "users"
        ENV["DIR"] = "test/fixtures/"
        @format = Flextures::ARGS.parse
      end
      should "directory name is exist" do
        assert_equal "test/fixtures/", @format.first[:dir]
      end
      should "set table name" do
        assert_equal "users", @format.first[:table]
      end
      should "file name is equal table name" do
        assert_equal "users", @format.first[:file]
      end
      teardown do
        ENV.delete("T")
        ENV.delete("DIR")
      end
    end
    context " D=option " do
      setup do
        ENV["T"] = "users"
        ENV["D"] = "test/fixtures/"
        @format = Flextures::ARGS.parse
      end
      should "directory name" do
        assert_equal "test/fixtures/", @format.first[:dir]
      end
      should "table name is exist" do
        assert_equal "users", @format.first[:table]
      end
      should "file name is equal table name" do
        assert_equal "users", @format.first[:file]
      end
      teardown do
        ENV.delete("T")
        ENV.delete("D")
      end
    end
    context " FIXTURES=option " do
      setup do
        ENV["T"] = "users"
        ENV["FIXTURES"] = "user_another"
        @format = Flextures::ARGS.parse
      end
      should "table name is exist" do
        assert_equal "users", @format.first[:table]
      end
      should " file name is changed by option's name " do
        assert_equal "user_another", @format.first[:file]
      end
      teardown do
        ENV.delete("T")
        ENV.delete("FIXTURES")
      end
    end
    context " MINUS option " do
      context "only one columns" do
        setup do
          ENV["T"]="users"
          ENV["MINUS"]="id"
          @format = Flextures::ARGS.parse
        end
        should " option contain 'minus' parameters" do
          assert_equal ["id"], @format.first[:minus]
        end
      end
      context "many columns" do
        setup do
          ENV["T"]="users"
          ENV["MINUS"]="id,created_at,updated_at"
          @format = Flextures::ARGS.parse
        end
        should " option contain 'minus' parameters" do
          assert_equal ["id","created_at","updated_at"], @format.first[:minus]
        end
      end
      teardown do
        ENV.delete("T")
        ENV.delete("MINUS")
      end
    end
    context " PLUS options " do
      setup do
        ENV["T"]="users"
      end
      context "only one columns" do
        setup do
          ENV["PLUS"]="hoge"
          @format = Flextures::ARGS.parse
        end
        should " option contain 'plus' parameters" do
          assert_equal ["hoge"], @format.first[:plus]
        end
      end
      context "many columns" do
        setup do
          ENV["PLUS"]="hoge,mage"
          @format = Flextures::ARGS.parse
        end
        should " option contain 'plus' parameters" do
          assert_equal ["hoge","mage"], @format.first[:plus]
        end
      end
      teardown do
        ENV.delete("T")
        ENV.delete("MINUS")
      end
    end
  end
end

