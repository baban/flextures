# encoding: utf-8

class FlexturesLoaderTest < Test::Unit::TestCase
  context Flextures::Loader do
    context "TRANSLATER" do
      context :binary do
        should "'nil' value not changed" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:binary].call(nil)
        end
      end
      context :boolean do
        should "'nil' value not changed" do
          assert_equal nil, Flextures::Loader::TRANSLATER[:boolean].call(nil)
        end
        should "'true' value not changed" do
          assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(true)
        end
        should "'false' value not changed" do
          assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call(false)
        end
        should "'0' is change to 'false'" do
          assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call(0)
        end
        should "'1' is change to 'true'" do
          assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(1)
        end
        should "'-1' is change to 'true'" do
          assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(-1)
        end
        should "'string data' is change to 'true'" do
          assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call("Hello")
        end
        should "'empty string' is change to 'true'" do
          assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call("")
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

    context ".stair_list" do
      context " stair is 'false' " do
        context "argument is null" do
          setup do
            @list = Flextures::Loader::stair_list nil, false
          end
          should " return array include only empty string" do
            assert_equal @list, [""]
          end
        end
        context "argument is empty string" do
          setup do
            @list = Flextures::Loader::stair_list "", false
          end
          should " return array include only empty string" do
            assert_equal @list, [""]
          end
        end
        context "include '/' mark" do
          setup do
            @list = Flextures::Loader::stair_list "a/b/c", false
          end
          should " return directory list" do
            assert_equal @list, ["a/b/c"]
          end
        end
      end
      context " stair is 'true' " do
        context "argument is null" do
          setup do
            @list = Flextures::Loader::stair_list nil, true
          end
          should " return array include only empty string" do
            assert_equal @list, [""]
          end
        end
        context "argument is empty string" do
          setup do
            @list = Flextures::Loader::stair_list "", true
          end
          should " return array include only empty string" do
            assert_equal @list, [""]
          end
        end
        context "include '/' mark" do
          setup do
            @list = Flextures::Loader::stair_list "a/b/c", true
          end
          should " return directory list" do
            assert_equal @list, ["a/b/c","a/b","a",""]
          end
        end
      end
    end
    
    context ".loading_order" do
      context "simple test" do
        setup do
          @proc = Flextures::Loader.loading_order
        end
        should "not sort" do
          assert_equal ["a","b","c"].sort(&@proc), ["a","b","c"]
        end
      end
      context "set orderd table name" do
        setup do
          Flextures::Config.table_load_order=["b"]
          @proc = Flextures::Loader.loading_order
        end
        should "first table name is setted table" do
          assert_equal ["a","b","c"].sort(&@proc), ["b","a","c"]
        end
        teardown do
          Flextures::Config.table_load_order=[]
        end
      end
    end
  end
end

