# flextures

* [ENGLISH DOCUMENT](https://github.com/baban/flextures/blob/master/README.md)

## Abstruct

このplug-inは、これまで開発中で溜まっていた
Rails標準のfixtureの不満点を解消するために作成しました
基本的な操作は単純で次のコマンドで
それぞれfixtureのロードとダンプを行います

```
rake db:flextures:load
rake db:flextures:dump
```

通常のfixtureとの主な違いは次の４点です

1. yamlよりもcsvを優先する
2. migrationでテーブル構成が変わっても、カラムの変更点を無視、補完してロードを行う
3. テーブル名とfixtureのファイル名を一致させないでも、自由なロード＆ダンプが出来るオプション
4. FactoyGirl風の読み込みフィルタで、Fixtureのデータを加工しながら読み込む事が出来る

## インストール方法

RailsのPlug-inとして使われることを想定しています
gem化されているので、bundlerで次のように記述して、普通にbundle install してください

```
 gem "flextures"
```

```
bundle install
bundle exec rails generator flextures:initializer
```

ちなみに開発環境はruby2.1以上のバージョン、rails4以上を想定しています

## 使い方

### rakeコマンド

次のコマンドで spec/fixtures/ 以下にあるfixtureのロード＆ダンプを行います
(読み込む基本のディレクトリは設定ファイルで変更可能)

```
rake db:flextures:load
rake db:flextures:dump
```

rake コマンドには以下の様な書式でオプションを指定することができます
指摘出来るオプションは、ロードとダンプで共通です

テーブル名で吐き出し(Userモデルusers)

```
rake db:flextures:dump TABLE=users
```

Usersモデルのfixture(users.csvか　users.yml)をロードする

```
rake db:flextures:load MODEL=User
```

その他オプションは以下の通りです:

| オプション | 役割                                                              |
------------|--------------------------------------------------------------------
| TABLE     | テーブル名を指定してロード。テーブル名はカンマ切りで複数指定が可能        |
| MODEL     | モデル名を指定してロード。モデル名はカンマ区切りで複数指定が可能          |
| DIR       | フィクスチャをロード＆ダンプするディレクトリを指定する                   |
| FILE      | loadまたはdumpするファイル名を直接指定(Userモデルのusers.csv以外を指定) |
| FORMAT    | ダンプ、またはロードするデータの種類を指定できる(csvかyml)              |
| OPTION    | その他の細かい読み込みオプションはここで指定出来ます                     |
| T         | TABLEのエイリアス                                                   |
| D         | ディレクトリ指定のエイリアス                                          |
| F         | ファイル名指定のエイリアス                                            |

migration等でテーブルの構成が変わった時には
generateコマンドを実行すると、テーブル情報のloadとdumpをセットで行なってくれるので便利です

```
rake db:flextures:generate T=users
```

さらに詳しい説明に関しては [Wiki:Rakeコマンドラインオプション](https://github.com/baban/flextures/wiki/Rake%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3)を参照して下さい

### Unit test flexture support

ユニットテスト中でデータの読み込みが行いたくなったときのために
fixtureのロード機能を使えます

次の例はRSpecからの読み込みですが
基本的な機能は、通常のfixturesと同じですので、fixtures と同じ感覚で使用して下さい

```ruby
describe ItemShopController do
  flextures :users, :items
end
```

基本的な違いは、yamlよりcsvを優先する、カラムの変更点を検知して警告を出しながらもロードを行う等ですが
もう一つ、ハッシュ引数で指定する事で、テーブル名、ファイル名を一致させなくても フィクスチャ を読み込ませることができます
そのため、すべてのテストケースで依存関係を気にしながら共通のfixtureを使わなくても良い様に出来ます

```ruby
describe ItemShopController do
  flextures :items, :users => :users_for_itemshop # users_for_itemshop.csv をロードする
end
```

その他現在はShouldからの呼び出しや様々なオプションを載せていますが
さらに詳しい使い方に関しては [Wiki:Unit Test Supportの説明](https://github.com/baban/flextures/wiki/Unit-test-support%E3%81%AE%E8%AA%AC%E6%98%8E) を参照して下さい

### Flextures load filter (and dump filter)

#### load filer

Railsのプロジェクトに `config/flextures.factory.rb` というファイルを作成して、そこにフィルタを記述することによって
フィクスチャの読み込み時に、値を加工して読み込む事が可能になっています
例えば、次の様に記述するとusersテーブルのlast_login_dateの値を、常に現在の時間として設定できます

```ruby
Flextures::Factory.define :users do |f|
  f.last_login_date = DateTime.now
end
```

テーブルにdefaultの値を設定していなくても
カラムのデータを適当に補完する機能があるので
大量のデータを生成したい時は次のように[faker](https://github.com/stympy/faker)等と組み合わせて
必要な分だけ生成をさせると、今までより若干捗るかもしれません

```ruby
require 'faker'
Flextures::Factory.define :users do |f|
  f.name= Faker::Name.name if !f.name  # ランダムで名前を生成(ただしUS仕様
  f.sex= [0,1].shuffle.first if !f.sex # 性別を設定
  # Factory Girlの様にhas_manyな感じのデータも生成できます。（初期設定でアイテムを２個持たせる）
  f.items<< [ Item.new( master_item_id: 1, count: 5 ), Item.new( master_item_id: 2, count: 3 ) ]
end
```

* [wiki:has_manyな感じのデータの精製法](https://github.com/baban/flextures/wiki/Has-many%E3%81%AA%E6%84%9F%E3%81%98%E3%81%AE%E3%83%87%E3%83%BC%E3%82%BF%E3%81%AE%E7%B2%BE%E8%A3%BD%E6%96%B9%E6%B3%95)

#### dump filer

データのdump時に加工が必要になった時には、同じく`config/flextures.factory.rb`に
テーブル名と、加工したい値をキーに、処理をラムダで渡してやることで可能です

```ruby
Flextures::DumpFilter.define :users, {
  :encrypted_password => lambda { |v| Base64.encode64(v) }
}
```

さらに細かい使い方に関しては [Wiki:FactoryFilterについて](https://github.com/baban/flextures/wiki/Factoryfilter%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6) を参照して下さい

### 設定ファイル

`config/initializers/flextures.rb`　で設定ファイルを作成すると、データをロード＆ダンプするディレクトリなどの設定を変更できます

```ruby
Flextures::Configuration.configure do |config|
  # Load and dump directory change "spec/fixtures/" to "test/fixtures/"
  config.load_directory = "test/fixtures/"
  config.dump_directory = "test/fixtures/"
end
```

その他の情報は [Wiki:設定ファイルの書式について](https://github.com/baban/flextures/wiki/%E8%A8%AD%E5%AE%9A%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%AE%E6%9B%B8%E5%BC%8F%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)を参照して下さい
