# encoding: utf-8

# ruby -I"lib:lib:test" -I"/Users/matsubaramasanao/.rvm/gems/ruby-1.9.3-p0/gems/rake-0.9.2.2/lib" "/Users/matsubaramasanao/.rvm/gems/ruby-1.9.3-p0/gems/rake-0.9.2.2/lib/rake/rake_test_loader.rb" test/**/test_*.rb
# ruby -I"lib:lib:test" "/Users/matsubaramasanao/.rvm/gems/ruby-1.9.3-p0/gems/rake-0.9.2.2/lib/rake/rake_test_loader.rb" test/**/test_*.rb

class FlexturesLoaderTest < Test::Unit::TestCase
  context Flextures::Loader do
    context "TRANSLATER" do
      context :binary do
        should "nil" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:binary].call(nil)
        end
      end
      context :boolean do
        should "nilはそのまま" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:boolean].call(nil)
        end
        should "trueもそのまま" do
          assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(true)
        end
        should "falseもそのまま" do
          assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call(false)
        end
        should "0" do
          assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call(0)
        end
        should "1" do
          assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(1)
        end
        should "-1" do
          assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(-1)
        end
        should "空白文字" do
          assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call("")
        end
        should "文字" do
          assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call("Hello")
        end
      end
      context :date do
        should "正常値の文字列" do
          assert_equal "2011/11/21", Flextures::Loader::TRANSLATER[:date].call("2011/11/21").strftime("%Y/%m/%d")
        end
        should "Timeオブジェクト" do
          now = Time.now
          assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:date].call(now).strftime("%Y/%m/%d")
        end
        should "DateTimeオブジェクト" do
          now = DateTime.now
          assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:date].call(now).strftime("%Y/%m/%d")
        end
        should "日付っぽい数字" do
          now = "20111121"
          assert_equal true, Flextures::Loader::TRANSLATER[:date].call(now).is_a?(Date)
        end
        should "nil" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:date].call(nil)
        end
        should "空文字" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:date].call("")
        end
      end
      context :datetime do
        should "正常値の文字列" do
          assert_equal "2011/11/21", Flextures::Loader::TRANSLATER[:date].call("2011/11/21").strftime("%Y/%m/%d")
        end
        should "Timeオブジェクト" do
          now = Time.now
          assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:date].call(now).strftime("%Y/%m/%d")
        end
        should "DateTimeオブジェクト" do
          now = DateTime.now
          assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:date].call(now).strftime("%Y/%m/%d")
        end
        should "日付っぽい数字" do
          now = "20111121"
          assert_equal true, Flextures::Loader::TRANSLATER[:date].call(now).is_a?(Date)
        end
        should "nil" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:date].call(nil)
        end
        should "空文字" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:date].call("")
        end
      end
      context :decimal do
        should "null" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:decimal].call(nil)
        end
      end
      context :float do
        should "null" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:float].call(nil)
        end
      end
      context :integer do
        should "null" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:integer].call(nil)
        end
      end
      context :string do
        should "null" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:string].call(nil)
        end
        should "空文字" do
          assert_equal "", Flextures::Loader::TRANSLATER[:string].call("")
        end
        should "タブ混じり" do
          s="\taaaaa"
          assert_equal s, Flextures::Loader::TRANSLATER[:string].call(s)
        end
        should "改行混じり" do
          s="aa\naaa"
          assert_equal s, Flextures::Loader::TRANSLATER[:string].call(s)
        end
        should "スペース混じり" do
          s="aa aaa"
          assert_equal s, Flextures::Loader::TRANSLATER[:string].call(s)
        end
        # "@#%{}|[]&:`'>?~"
      end
      context :text do
        should "null" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:text].call(nil)
        end
        should "空文字" do
          assert_equal "", Flextures::Loader::TRANSLATER[:text].call("")
        end
      end
      context :time do
        should "正常値の文字列" do
          assert_equal "2011/11/21", Flextures::Loader::TRANSLATER[:time].call("2011/11/21").strftime("%Y/%m/%d")
        end
        should "Timeオブジェクト" do
          now = Time.now
          assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:time].call(now).strftime("%Y/%m/%d")
        end
        should "DateTimeオブジェクト" do
          now = DateTime.now
          assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:time].call(now).strftime("%Y/%m/%d")
        end
        should "日付っぽい数字はDateTime型" do
          now = "20111121"
          assert_equal true, Flextures::Loader::TRANSLATER[:time].call(now).is_a?(DateTime)
        end
        should "nilはnilのまま" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:time].call(nil)
        end
        should "空文字はnil" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:time].call("")
        end
      end
      context :timestamp do
        should "正常値の文字列はDateTimeに変換" do
          assert_equal "2011/11/21", Flextures::Loader::TRANSLATER[:timestamp].call("2011/11/21").strftime("%Y/%m/%d")
        end
        should "Timeオブジェクト" do
          now = Time.now
          assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:timestamp].call(now).strftime("%Y/%m/%d")
        end
        should "DateTimeオブジェクトはDateTime" do
          now = DateTime.now
          assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:timestamp].call(now).strftime("%Y/%m/%d")
        end
        should "日付っぽい数字はDateTime" do
          now = "20111121"
          assert_equal true, Flextures::Loader::TRANSLATER[:timestamp].call(now).is_a?(DateTime)
        end
        should "nilからnil" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:timestamp].call(nil)
        end
        should "空文字はnil" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:timestamp].call("")
        end
      end
    end
  end
end

