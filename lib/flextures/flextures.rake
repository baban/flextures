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
      # TODO: deprecated message
      # please use 'FOAMRT=csv' option
      ENV["FORMAT"]="csv"
      Flextures::Rake::Command::dump
    end

    desc "Dump data to yaml format"
    task :ymldump => :environment do
      puts "This command is deprecated"
      puts "please use 'rake db:flextures:dump FORMAT='yml''"
      # TODO: deprecated message
      # please use 'FOAMRT=yml' option
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
      # TODO: deprecated message
      # please use 'FOAMRT=csv' option
      ENV["FORMAT"]="csv"
      Flextures::Rake::Command::load
    end

    desc "load fixture files only yaml format"
    task :ymlload => :environment do
      # TODO: deprecated message
      # please use 'FOAMRT=yml' option
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
