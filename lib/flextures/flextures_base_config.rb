# encoding: utf-8

# 基本設定を記述する
module Flextures
  module Config
    @@read_onlys=[]
    @@configs={
      ignore_tables: ["schema_migrations"],
      fixture_load_directory: "spec/fixtures/",
      fixture_dump_directory: "spec/fixtures/",
      error_level:"loose",    # エラーに対して無視か警告かエラーメッセージ表示かを選べる
      init_all_tables: false,  # 実行後に全テーブルの初期化を行うか？falseにするとそのぶん高速化できる
    }
    # ハッシュをsetter、getterに変換
    class<< self
      @@configs.each do |setting_key, setting_value|
        define_method(setting_key){ @@configs[setting_key] }
        define_method("#{setting_key}="){ |arg| @@configs[setting_key]=arg } unless @@read_onlys.include?(setting_key)
      end
    end
  end
end


