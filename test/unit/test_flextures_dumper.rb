# encoding: utf-8

# ruby -I"lib:lib:test" -I"/Users/matsubaramasanao/.rvm/gems/ruby-1.9.3-p0/gems/rake-0.9.2.2/lib" "/Users/matsubaramasanao/.rvm/gems/ruby-1.9.3-p0/gems/rake-0.9.2.2/lib/rake/rake_test_loader.rb" test/**/test_*.rb
# ruby -I"lib:lib:test" "/Users/matsubaramasanao/.rvm/gems/ruby-1.9.3-p0/gems/rake-0.9.2.2/lib/rake/rake_test_loader.rb" test/**/test_*.rb

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
      context :float do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:float]
          end
          should "「integer」はそのまま" do
            assert_equal 10, @trans.call( 10, :yml )
          end
          should "「float」はそのまま" do
            assert_equal 1.5, @trans.call( 1.5, :yml )
          end
          should "「nil」は文字列「'null'」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "「0」は数字「0」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "「false」は「false」のまま" do
            assert_equal "null", @trans.call( nil, :yml )
          end
        end
        context :csv do
        end
      end
      context :integer do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:integer]
          end
          should "「integer」はそのまま" do
            assert_equal 10, @trans.call( 10, :yml )
          end
          should "「float」は切り捨て" do
            assert_equal 1, @trans.call( 1.5, :yml )
          end
          should "「nil」は文字列　「'null'」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "「0」は「0」" do
            assert_equal 0, @trans.call( 0, :yml )
          end
          should "「false」は「0」" do
            assert_equal 0, @trans.call( false, :yml )
          end
          should "「true」は「1」" do
            assert_equal 1, @trans.call( true, :yml )
          end
        end
        context :csv do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:integer]
          end
          should "「integer」はそのまま" do
            assert_equal 10, @trans.call( 10, :csv )
          end
          should '「nil」は文字列「""」' do
            assert_equal "", @trans.call( nil, :csv )
          end
        end
      end
      context :string do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:string]
          end
          should "「nil」は文字列「'null'」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "「空文字」は空文字を返す「''」" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "「false」は「false」" do
            assert_equal false, @trans.call( false, :yml )
          end
          should "「true」は「true」" do
            assert_equal true, @trans.call( true, :yml )
          end
        end
      end
      context :null do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:null]
          end
          should "values is 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end
        end
        context :csv do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:null]
          end
          should "values is empty string" do
            assert_equal "", @trans.call( nil, :csv )
          end
        end
      end
    end
  end
end

