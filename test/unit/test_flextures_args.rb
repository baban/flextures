# encoding: utf-8

class FlexturesArgsTest < Test::Unit::TestCase
  context Flextures::ARGS do
    context " TABLE=テーブル名 を設定している場合 " do
      setup do
        ENV["TABLE"] = "users"
        @format = Flextures::ARGS.parse
      end
      should "テーブル名を指定できている" do
        assert_equal "users", @format.first[:table]
      end
      should "ファイル名はテーブル名と同じ" do
        assert_equal "users", @format.first[:file]
      end
      teardown do
        ENV.delete("TABLE")
      end
    end
    context " T=テーブル名を設定している場合 " do
      setup do
        ENV["T"] = "s_user"
        @format = Flextures::ARGS.parse
      end
      should "テーブル名を指定できている" do
        assert_equal "s_user", @format.first[:table]
      end
      should "ファイル名はテーブル名と同じ" do
        assert_equal "s_user", @format.first[:file]
      end
      teardown do
        ENV.delete("T")
      end
    end
    context " DIR=でダンプするディレクトリを変更できる " do
      setup do
        ENV["T"] = "users"
        ENV["DIR"] = "test/fixtures/"
        @format = Flextures::ARGS.parse
      end
      should "ディレクトリ名を取得できる" do
        assert_equal "test/fixtures/", @format.first[:dir]
      end
      should "テーブル名を指定できている" do
        assert_equal "users", @format.first[:table]
      end
      should "ファイル名はテーブル名と同じ" do
        assert_equal "users", @format.first[:file]
      end
      teardown do
        ENV.delete("T")
        ENV.delete("DIR")
      end
    end
    context " D=でもダンプするディレクトリを変更できる " do
      setup do
        ENV["T"] = "users"
        ENV["D"] = "test/fixtures/"
        @format = Flextures::ARGS.parse
      end
      should "ディレクトリ名を取得できる" do
        assert_equal "test/fixtures/", @format.first[:dir]
      end
      should "テーブル名を指定できている" do
        assert_equal "users", @format.first[:table]
      end
      should "ファイル名はテーブル名と同じ" do
        assert_equal "users", @format.first[:file]
      end
      teardown do
        ENV.delete("T")
        ENV.delete("D")
      end
    end
    context " FIXTURES=でもダンプするファイルを変更できる " do
      setup do
        ENV["T"] = "users"
        ENV["FIXTURES"] = "user_another"
        @format = Flextures::ARGS.parse
      end
      should "テーブル名は指定したもの" do
        assert_equal "users", @format.first[:table]
      end
      should "ファイル名はテーブル名と違う指定したものに変わっている" do
        assert_equal "user_another", @format.first[:file]
      end
      teardown do
        ENV.delete("T")
        ENV.delete("FIXTURES")
      end
    end
  end
end

