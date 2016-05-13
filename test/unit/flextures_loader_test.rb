$:.push( File.join(File.dirname(File.expand_path(__FILE__)), '../') )
require 'test_helper'

describe Flextures::Loader do
  describe "TRANSLATER" do
    describe :binary do
      it "'nil' value not changed" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:binary].call(nil)
      end
    end

    describe :boolean do
      it "'nil' value not changed" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:boolean].call(nil)
      end

      it "true value not changed" do
        assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(true)
      end

      it "false value not changed" do
        assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call(false)
      end

      it "0 is change to 'false'" do
        assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call(0)
      end

      it "1 is change to 'true'" do
        assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(1)
      end

      it "-1 is change to 'true'" do
        assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call(-1)
      end

      it "'0' is change to 'false'" do
        assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call('0')
      end

      it "'1' is change to 'true'" do
        assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call('1')
      end

      it "'true' value not changed" do
        assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call('true')
      end

      it "'false' value not changed" do
        assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call('false')
      end

      it "'non-falsy string data' is change to 'true'" do
        assert_equal true, Flextures::Loader::TRANSLATER[:boolean].call("Hello")
      end

      it "'empty string' is change to 'true'" do
        assert_equal false, Flextures::Loader::TRANSLATER[:boolean].call("")
      end
    end

    describe :date do
      it "正常値の文字列" do
        assert_equal "2011/11/21", Flextures::Loader::TRANSLATER[:date].call("2011/11/21").strftime("%Y/%m/%d")
      end

      it "Timeオブジェクト" do
        now = Time.now
        assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:date].call(now).strftime("%Y/%m/%d")
      end

      it "DateTimeオブジェクト" do
        now = DateTime.now
        assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:date].call(now).strftime("%Y/%m/%d")
      end

      it "日付っぽい数字" do
        now = "20111121"
        assert_equal true, Flextures::Loader::TRANSLATER[:date].call(now).is_a?(Date)
      end

      it "nil" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:date].call(nil)
      end

      it "空文字" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:date].call("")
      end
    end

    describe :datetime do
      it "正常値の文字列" do
        assert_equal "2011/11/21", Flextures::Loader::TRANSLATER[:date].call("2011/11/21").strftime("%Y/%m/%d")
      end

      it "Timeオブジェクト" do
        now = Time.now
        assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:date].call(now).strftime("%Y/%m/%d")
      end

      it "DateTimeオブジェクト" do
        now = DateTime.now
        assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:date].call(now).strftime("%Y/%m/%d")
      end

      it "日付っぽい数字" do
        now = "20111121"
        assert_equal true, Flextures::Loader::TRANSLATER[:date].call(now).is_a?(Date)
      end

      it "nil" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:date].call(nil)
      end

      it "空文字" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:date].call("")
      end
    end

    describe :decimal do
      it "null" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:decimal].call(nil)
      end
    end

    describe :float do
      it "null" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:float].call(nil)
      end
    end

    describe :integer do
      it "null" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:integer].call(nil)
      end
    end

    describe :string do
      it "null" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:string].call(nil)
      end

      it "空文字" do
        assert_equal "", Flextures::Loader::TRANSLATER[:string].call("")
      end

      it "タブ混じり" do
        s="\taaaaa"
        assert_equal s, Flextures::Loader::TRANSLATER[:string].call(s)
      end

      it "改行混じり" do
        s="aa\naaa"
        assert_equal s, Flextures::Loader::TRANSLATER[:string].call(s)
      end

      it "スペース混じり" do
        s="aa aaa"
        assert_equal s, Flextures::Loader::TRANSLATER[:string].call(s)
      end
      # "@#%{}|[]&:`'>?~"
    end

    describe :text do
      it "null" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:text].call(nil)
      end

      it "空文字" do
        assert_equal "", Flextures::Loader::TRANSLATER[:text].call("")
      end
    end

    describe :time do
      it "正常値の文字列" do
        assert_equal "2011/11/21", Flextures::Loader::TRANSLATER[:time].call("2011/11/21").strftime("%Y/%m/%d")
      end

      it "Timeオブジェクト" do
        now = Time.now
        assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:time].call(now).strftime("%Y/%m/%d")
      end

      it "DateTimeオブジェクト" do
        now = DateTime.now
        assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:time].call(now).strftime("%Y/%m/%d")
      end

      it "日付っぽい数字はDateTime型" do
        now = "20111121"
        assert_equal true, Flextures::Loader::TRANSLATER[:time].call(now).is_a?(DateTime)
      end

      it "nilはnilのまま" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:time].call(nil)
      end

      it "空文字はnil" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:time].call("")
      end
    end

    describe :timestamp do
      it "正常値の文字列はDateTimeに変換" do
        assert_equal "2011/11/21", Flextures::Loader::TRANSLATER[:timestamp].call("2011/11/21").strftime("%Y/%m/%d")
      end

      it "Timeオブジェクト" do
        now = Time.now
        assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:timestamp].call(now).strftime("%Y/%m/%d")
      end

      it "DateTimeオブジェクトはDateTime" do
        now = DateTime.now
        assert_equal now.strftime("%Y/%m/%d"), Flextures::Loader::TRANSLATER[:timestamp].call(now).strftime("%Y/%m/%d")
      end

      it "日付っぽい数字はDateTime" do
        now = "20111121"
        assert_equal true, Flextures::Loader::TRANSLATER[:timestamp].call(now).is_a?(DateTime)
      end

      it "nilからnil" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:timestamp].call(nil)
      end

      it "空文字はnil" do
        assert_equal nil, Flextures::Loader::TRANSLATER[:timestamp].call("")
      end
    end
    describe ".stair_list" do
      describe " stair is 'false' " do
        describe "argument is null" do
          before do
            @list = Flextures::Loader::stair_list nil, false
          end

          it " return array include only empty string" do
            assert_equal @list, [""]
          end
        end
        describe "argument is empty string" do
          before do
            @list = Flextures::Loader::stair_list "", false
          end

          it " return array include only empty string" do
            assert_equal @list, [""]
          end
        end

        describe "include '/' mark" do
          before do
            @list = Flextures::Loader::stair_list "a/b/c", false
          end

          it " return directory list" do
            assert_equal @list, ["a/b/c"]
          end
        end
      end

      describe " stair is 'true' " do
        describe "argument is null" do
          before do
            @list = Flextures::Loader::stair_list nil, true
          end

          it " return array include only empty string" do
            assert_equal @list, [""]
          end
        end

        describe "include '/' mark" do
          before do
            @list = Flextures::Loader::stair_list "a/b/c", true
          end

          it " return directory list" do
            assert_equal @list, ["a/b/c","a/b","a",""]
          end
        end
      end

      describe ".loading_order" do
        describe "simple test" do
          before do
            @proc = Flextures::Loader.loading_order
          end

          it "not sort" do
            assert_equal ["a","b","c"].sort(&@proc), ["a","b","c"]
          end
        end

        describe "set orderd table name" do
          before do
            Flextures::Configuration.table_load_order=["b"]
            @proc = Flextures::Loader.loading_order
          end

          it "first table name is setted table" do
            assert_equal ["a","b","c"].sort(&@proc), ["b","a","c"]
          end

          after do
            Flextures::Configuration.table_load_order=[]
          end
        end
      end
    end
  end
end
