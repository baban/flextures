# encoding: utf-8

require 'flextures/flextures'

namespace :db do
  namespace :flextures do
    desc "Dump data to csv format"
    task :dump => :environment do
      Flextures::Rake::Command::dump
    end

    desc "Dump data to prefer csv format"
    task :csvdump => :environment do
      puts "This command is deprecated"
      puts "please use 'rake db:flextures:dump FORMAT='csv''"
      # TODO: deprecatedを出す
      ENV["FORMAT"]="csv"
      Flextures::Rake::Command::dump
    end

    desc "Dump data to yaml format"
    task :ymldump => :environment do
      puts "This command is deprecated"
      puts "please use 'rake db:flextures:dump FORMAT='yml''"
      # TODO: deprecatedを出す
      # FOAMRT=ymlで置き換えるように設定
      ENV["FORMAT"]="yml"
      Flextures::Rake::Command::dump
    end

    desc "load fixture data csv format"
    task :load => :environment do
      Flextures::Rake::Command::load
    end

    desc "load fixture data only csv format files"
    task :csvload => :environment do
      puts "This command is deprecated"
      puts "please use 'rake db:flextures:load FORMAT='csv''"
      # TODO: deprecatedを出す
      ENV["FORMAT"]="csv"
      Flextures::Rake::Command::load
    end

    desc "load fixture files only yaml format"
    task :ymlload => :environment do
      # TODO: deprecatedを出す
      # FORMAT=ymlで指定を行う
      ENV["FORMAT"]="yml"
      puts "This command is deprecated"
      puts "please use 'rake db:flextures:load FORMAT='yml''"
      Flextures::Rake::Command::load
    end

    desc "load and dump file (replace) new data file"
    task :generate => :environment do
      Flextures::Rake::Command::generate
    end 
  end
end
