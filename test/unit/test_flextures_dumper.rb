# encoding: utf-8

class FlexturesDumperTest < Test::Unit::TestCase
  context Flextures::Dumper do
    should "データの型が一致" do
      assert_equal Module, Flextures::Dumper.class
    end

    context "データ型を以下のフォーマットに変換" do
      context :binary do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:binary]
          end
          should "「nil」は文字列「'null'」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
        end
        context :csv do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:binary]
          end
        end
      end
      context :boolean do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:boolean]
          end
          should "「nil」は文字列「'null'」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "「0」は「false」" do
            assert_equal false,  @trans.call( 0, :yml )
          end
          should "「0以外の数」は「true」" do
            assert_equal true,   @trans.call( 1, :yml )
          end
          should "「空文字」は「false」" do
            assert_equal false,  @trans.call( "", :yml )
          end
          should "「文字列」は「true」" do
            assert_equal true,  @trans.call( "Hello", :yml )
          end
        end
        context :csv do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:boolean]
          end
        end
      end
      context :date do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:date]
          end
          should "「nil」は文字列「'null'」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "「空文字」は文字列「'null'」" do
            assert_equal "null", @trans.call( "", :yml )
          end
          should "「false」は文字列「'null'」" do
            assert_equal "null", @trans.call( false, :yml )
          end
        end
        context :csv do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:date]
          end
        end
      end
      context :datetime do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:datetime]
          end
          should "「nil」は文字列「'null'」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "「空文字」は文字列「'null'」" do
            assert_equal "null", @trans.call( "", :yml )
          end
          should "「false」は文字列「'null'」" do
            assert_equal "null", @trans.call( false, :yml )
          end
        end
        context :csv do
        end
      end
    end
  end
end

