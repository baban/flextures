# encoding: utf-8

class FlexturesHookTest < Test::Unit::TestCase
  context Flextures::Loader do
    context ".parse_flextures_options" do
      context "通常動作" do
        setup do
          @ret, option = Flextures::Loader.parse_flextures_options(:users)
        end
        should "指定したテーブル分だけハッシュが返されている" do
          assert_equal 1, @ret.size
        end
        should "ハッシュの中身は読み込み設定のハッシュ" do
          h = { table: :users, file: :users, loader: :fun }
          assert_equal h, @ret.first
        end
      end
      context "違うファイルをロードした時" do
        setup do
          @ret, option = Flextures::Loader.parse_flextures_options( :users => :users_another3 )
        end
        should "指定したテーブル分だけハッシュが返されている" do
          assert_equal 1, @ret.size
        end
        should "ハッシュの中身は読み込み設定のハッシュ" do
          h = { table: :users, file: :users_another3, loader: :fun }
          assert_equal h, @ret.first
        end
      end
    end

  end
end

