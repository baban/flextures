$:.push( File.join(File.dirname(File.expand_path(__FILE__)), '../') )
require 'test_helper'

describe Flextures::Dumper do
  describe "TRANSLATE function rules" do
    describe :binary do
      describe :yml do
        before do
          @trans = Flextures::Dumper::TRANSLATER[:binary]
        end

        it "nil translate 'null' string" do
          assert_equal "null", @trans.call( nil, :yml )
        end
      end

      describe :binary do
        describe :csv do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:binary]
          end
        end
      end

      describe :boolean do
        describe :yml do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:boolean]
          end

          it "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end

          it "0 translate false" do
            assert_equal false,  @trans.call( 0, :yml )
          end

          it "natural number translat true" do
            assert_equal true,   @trans.call( 1, :yml )
          end

          it " empty string translate dalse" do
            assert_equal false,  @trans.call( "", :yml )
          end

          it "string translate true" do
            assert_equal true,  @trans.call( "Hello", :yml )
          end
        end

        describe :csv do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:boolean]
          end
        end
      end

      describe :date do
        describe :yml do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:date]
          end

          it "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end

          it "empty string translate 'null' string" do
            assert_equal "null", @trans.call( "", :yml )
          end

          it "false translate 'null' string" do
            assert_equal "null", @trans.call( false, :yml )
          end
        end

        describe :csv do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:date]
          end
        end
      end

      describe :datetime do
        describe :yml do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:datetime]
          end

          it "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end

          it "empty string translate 'null' string" do
            assert_equal "null", @trans.call( "", :yml )
          end

          it "false translate 'null' string" do
            assert_equal "null", @trans.call( false, :yml )
          end
        end

        describe :csv do
        end
      end

      describe :float do
        describe :yml do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:float]
          end

          it "integral number don't translate" do
            assert_equal 10, @trans.call( 10, :yml )
          end

          it "floating number don't translate" do
            assert_equal 1.5, @trans.call( 1.5, :yml )
          end

          it "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end

          it "0 don't translate" do
            assert_equal "null", @trans.call( nil, :yml )
          end

          it "false don't translate" do
            assert_equal "null", @trans.call( nil, :yml )
          end
        end

        describe :csv do
        end
      end

      describe :integer do
        describe :yml do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:integer]
          end

          it "integral number don't translate" do
            assert_equal 10, @trans.call( 10, :yml )
          end

          it "float number is floored" do
            assert_equal 1, @trans.call( 1.5, :yml )
          end

          it "nil translate 'null' string" do
            assert_equal "null", @trans.call( nil, :yml )
          end

          it "0 don't translate" do
            assert_equal 0, @trans.call( 0, :yml )
          end

          it "false translate 0" do
            assert_equal 0, @trans.call( false, :yml )
          end

          it "true translate 1" do
            assert_equal 1, @trans.call( true, :yml )
          end
        end

        describe :csv do
          before do
            @trans = Flextures::Dumper::TRANSLATER[:integer]
          end

          it "integral number don't translate" do
            assert_equal 10, @trans.call( 10, :csv )
          end

          it 'nil translate empty string' do
            assert_equal "", @trans.call( nil, :csv )
          end
        end

        describe :string do
          describe :yml do
            before do
              @trans = Flextures::Dumper::TRANSLATER[:string]
            end

            it "nil translate 'null' string" do
              assert_equal "null", @trans.call( nil, :yml )
            end

            it "empty string don't translate" do
              assert_equal "null", @trans.call( nil, :yml )
            end

            it "false don't translate" do
              assert_equal false, @trans.call( false, :yml )
            end

            it "true don't translate" do
              assert_equal true, @trans.call( true, :yml )
            end
          end
        end

        describe :null do
          describe :yml do
            before do
              @trans = Flextures::Dumper::TRANSLATER[:null]
            end

            it "values is 'null' string" do
              assert_equal "null", @trans.call( nil, :yml )
            end
          end

          describe :csv do
            before do
              @trans = Flextures::Dumper::TRANSLATER[:null]
            end

            it "values is empty string" do
              assert_equal "", @trans.call( nil, :csv )
            end
          end
        end
      end
    end
  end
end
