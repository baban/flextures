# encoding: utf-8

class FlexturesHookTest < Test::Unit::TestCase
  context Flextures::Loader do
    context ".parse_flextures_options" do
      context "通常動作" do
        should "指定したテーブル分だけハッシュが返されている" do
          assert_equal 1, Flextures::Loader.parse_flextures_options(:users).size
        end
        should "ハッシュの中身は読み込み設定のハッシュ" do
          h = { table: :users, file: :users, loader: :fun }
          assert_equal h, Flextures::Loader.parse_flextures_options(:users).first
        end
      end      
    end
  end
end

