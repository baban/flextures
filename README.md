# flextures

* [日本語版ドキュメント(Japanese Document)](https://github.com/baban/flextures/blob/master/README.ja.md)

![Ruby 2.1 higher](https://img.shields.io/badge/ruby-v2.1-red.svg)
![Rails 4.0 higher](https://img.shields.io/badge/rails-v4.0-red.svg)
![MIT Licence](https://img.shields.io/badge/licence-MIT-blue.svg)

## Description

This plug-in aim to resolve many problems, durling rails developping about fixtures.
Basic commands is simple.
Each commands load or dump fixtures.

```
rake db:flextures:load
rake db:flextures:dump
```

Major different point is four.

1. Fixture file prefered CSV to YAML.
2. loading don't stop, if table columns are not match fixture file's column
3. Fixture file name can change, if file name is not equal table name.
4. Fixture data can translate to use filter, like factory girl.

## Table of Contents

* [Requirements](#requirements)
* [Usage](#usage)
  * [How to install](#how_to_install)
  * [rake command](#commandline_support)
  * [Unit test support](#unittest_support)
  * [Flextures load & dump filter](#flextures_filter)
  * [Configuration file](#configuration)
* [Contributing](#contributing)
* [License](#licence)

<a name="requirements"></a>
## Requirements

* ruby2.1 higher

<a name="usage"></a>
## Usage

<a name="how_to_install"></a>
## How to install

This program is implemented Rails Plug-in.
If You want to install this plug-in.
Please use bundler.

In `Gemfile`

```
gem "flextures"
```

And execute below commands.

```
bundle install
bundle exec rails generator flextures:initializer
```

(Development emnvoriment must be ruby2.1 higer and rails3 higher)

<a name="commandline_support"></a>
### rake command

load command input fixtures file under "spec/fixtures/".
(Loading directory can change configuration file)

```
rake db:flextures:load
rake db:flextures:dump
```

rake command can set options.
For example, this option set dump file name.
(Option dump only "users.csv")

```
rake db:flextures:dump TABLE=users
```

Other options...

| option | description                         |
---------|--------------------------------------
| TABLE  | set table name                      |
| MODEL  | set model name                      |
| DIR    | set directory name                  |
| FILE   | set fixture file name               |
| FORMAT | change dump file format(csv or yml) |
| OPTION | other options                       |
| T      | alias TABLE option                  |
| D      | alias DIR option                    |
| F      | alias FIXTURES option               |

if you change table colum information
next comannd regenerate (load fixture and dump) fixtures

```
rake db:flextures:generate T=users
```

Other information please see [wiki](https://github.com/baban/flextures/wiki/Rake-command-option) ...

<a name="unittest_support"></a>
### Unit test support

Fixture load function implemented for Unittes Tools (for example, RSpec, Shoulda).

```ruby
describe ItemShopController do
  flextures :users, :items
end
```

flexture function can write like a "fixture" function, implemented in RSpec.
But, "flexture" function ignore columns change.

Flextures function can change load file name.

```ruby
describe ItemShopController do
  flextures :items, :users => :users_for_itemshop # load "users_for_itemshop.csv"
end
```

Other option information
Please see [wiki](https://github.com/baban/flextures/wiki/Unittestsupport) ...

<a name="flextures_filter"></a>
### Flextures load & dump filter

#### load filter

In `config/flextures.factory.rb`

Factory filter translate fixture data and set database.

For example, this code set current time to last_login_date column.

```ruby
Flextures::Factory.define :users do |f|
  f.last_login_date = DateTime.now
end
 ```

This sample, generate name and sex automatically, and other tables data generate

```ruby
require 'faker'
Flextures::Factory.define :users do |f|
  f.name= Faker::Name.name if !f.name  # gemerate name
  f.sex= [0,1].shuffle.first if !f.sex # generate sex
  # factory filter can generate data, use has_many association
  f.items<< [ Item.new( master_item_id: 1, count: 5 ), Item.new( master_item_id: 2, count: 3 ) ]
end
```

### dump filter

if you need to convert table data into other data format, you use dump filter.
(dump filter is same file as load filter)

dump filter has hash arguments, it is formatted colum name key and convert method, proc, lambda value

file is `config/flextures.factory.rb`

```ruby
Flextures::DumpFilter.define :users, {
  :encrypted_password => lambda { |v| Base64.encode64(v) }
}
 ```

Other options please see [wiki](https://github.com/baban/flextures/wiki/Factoryfilter) ...

<a name="configuration"></a>
### Configuration file

In `config/initializers/flextures.rb`, configuration file can change load and dump directory

```ruby
Flextures::Configuration.configure do |config|
  # Load and dump directory change "spec/fixtures/" to "test/fixtures/"
  config.load_directory = "test/fixtures/"
  config.dump_directory = "test/fixtures/"
end
```

Other options please see [wiki](https://github.com/baban/flextures/wiki/Configuration-file) ...

<a name="contributing"></a>
## Contributing

https://github.com/baban/flextures/graphs/contributors

<a name="licence"></a>
## Licence

This software is released under the [MIT Licence](http://www.opensource.org/licenses/MIT).
