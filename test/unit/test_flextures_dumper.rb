# encoding: utf-8
=begin
class FlexturesDumperTest < Test::Unit::TestCase
  context Flextures::Dumper do
    context "TRANSLATE function rules" do
      context :binary do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:binary]
          end
          should "nil translate 'null' string" do
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
          should "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "0 translate false" do
            assert_equal false,  @trans.call( 0, :yml )
          end
          should "natural number translat true" do
            assert_equal true,   @trans.call( 1, :yml )
          end
          should " empty string translate dalse" do
            assert_equal false,  @trans.call( "", :yml )
          end
          should "string translate true" do
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
          should "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "empty string translate 'null' string" do
            assert_equal "null", @trans.call( "", :yml )
          end
          should "false translate 'null' string" do
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
          should "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "empty string translate 'null' string" do
            assert_equal "null", @trans.call( "", :yml )
          end
          should "false translate 'null' string" do
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
          should "integral number don't translate" do
            assert_equal 10, @trans.call( 10, :yml )
          end
          should "floating number don't translate" do
            assert_equal 1.5, @trans.call( 1.5, :yml )
          end
          should "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "0 don't translate" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "false don't translate" do
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
          should "integral number don't translate" do
            assert_equal 10, @trans.call( 10, :yml )
          end
          should "float number is floored" do
            assert_equal 1, @trans.call( 1.5, :yml )
          end
          should "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "0 don't translate" do
            assert_equal 0, @trans.call( 0, :yml )
          end
          should "false translate 0" do
            assert_equal 0, @trans.call( false, :yml )
          end
          should "true translate 1" do
            assert_equal 1, @trans.call( true, :yml )
          end
        end
        context :csv do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:integer]
          end
          should "integral number don't translate" do
            assert_equal 10, @trans.call( 10, :csv )
          end
          should 'nil translate empty string' do
            assert_equal "", @trans.call( nil, :csv )
          end
        end
      end
      context :string do
        context :yml do
          setup do
            @trans = Flextures::Dumper::TRANSLATER[:string]
          end
          should "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "empty string don't translate" do
            assert_equal "null", @trans.call( nil, :yml )
          end
          should "false don't translate" do
            assert_equal false, @trans.call( false, :yml )
          end
          should "true don't translate" do
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
=end
