= flextures

* {日本語版ドキュメント(Japanese Document)}[https://github.com/baban/flextures/blob/master/README.ja.rdoc]

== Abstruct

This plug-in aim to resolve many problems, durling rails developping about fixtures.
Basic commands is simple.
Each commands load or dump fixtures.

 rake db:flextures:load
 rake db:flextures:dump

Major different point is four.

1. Fixture file prefered CSV to YAML.
2. loading don't stop, if table columns are not match fixture file's column
3. Fixture file name can change, if file name is not equal table name. 
4. Fixture data can translate to use filter, like factory girl.

== How to install

This program is implemented Rails Plug-in.
You want to install this plug-in.
Please use bundler.

 gem "flextures"

(Development emnvoriment must be ruby1.9 higer and rails3 higher)

== How to use

=== rake command

load command input fixtures file under "spec/fixtures/".
(Loading directory can change configuration file)

 rake db:flextures:load
 rake db:flextures:dump

rake command can set options.
For example, this option set dump file name.
(Option dump only "users.csv")

 rake db:flextures:dump TABLE=users

Other options...

 TABLE : set table name
 MODEL : set model name
 DIR : set directory name
 FILE : set fixture file name
 FORMAT：change dump file format(csv or yml)
 OPTION：other options
 T : alias TABLE option
 D : alias DIR option
 F : alias FIXTURES option

if you change table colum information
next comannd regenerate (load fixture and dump) fixtures

 rake db:flextures:generate T=users

Other information please see {wiki}[https://github.com/baban/flextures/wiki/Rake-command-option] ...

=== Unit test flexture support

Fixture load function implemented for Unittes Tools (for example, RSpec, Shoulda).

 describe ItemShopController do
   flextures :users, :items

flexture function can write like a "fixture" function, implemented in RSpec.
But, "flexture" function ignore columns change.

Flextures function can change load file name.

 describe ItemShopController do
   flextures :items, :users => :users_for_itmshop # load "users_for_itemshop.csv"

Other option information
Please see {wiki}[https://github.com/baban/flextures/wiki/Unittestsupport] ...

=== Flextures load & dump filter

==== load filter

If you create filter file.(File name is "config/flextures.factory.rb")
Factory filter translate fixture data and set database.

For example, this code set current time to last_login_date column.

 Flextures::Factory.define :users do |f| 
   f.last_login_date = DateTime.now
 end

This sample, generate name and sex automatically, and other tables data generate

 require 'faker'
 Flextures::Factory.define :users do |f|
   f.name= Faker::Name.name if !f.name  # gemerate name
   f.sex= [0,1].shuffle.first if !f.sex # generate sex
   # factory filter can generate data, use has_many association
   f.items<< [ Item.new( master_item_id: 1, count: 5 ), Item.new( master_item_id: 2, count: 3 ) ]
 end

==== dump filter

if you need to convert table data into other data format, you use dump filter.
(dump filter is same file as load filter)

dump filter has hash argumtne, it is formatted colum name key and convert method, proc, lambda value

 Flextures::DumpFilter.define :users, {
   :encrypted_password => lambda { |v| Base64.encode64(v) }
 }

Other options please see {wiki}[https://github.com/baban/flextures/wiki/Factoryfilter] ...

=== Configuration file

Configuration file can change load and dump directory
(file is config/flextures.config.rb)

 # config/flextures.config.rb
 module Flextures
   # Load and dump directory change "spec/fixtures/" to "test/fixtures/"
   Config.fixture_load_directory = "test/fixtures/"
   Config.fixture_dump_directory = "test/fixtures/"
 end

Other options please see {wiki}[https://github.com/baban/flextures/wiki/Configuration-file] ...

