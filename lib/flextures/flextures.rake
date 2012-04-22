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
      Flextures::Rake::Command::csvdump
    end

    desc "Dump data to yaml format"
    task :ymldump => :environment do
      Flextures::Rake::Command::ymldump
    end

    desc "load fixture data csv format"
    task :load => :environment do
      Flextures::Rake::Command::load
    end

    desc "load fixture data only csv format files"
    task :csvload => :environment do
      Flextures::Rake::Command::csvload
    end

    desc "load fixture files only yaml format"
    task :ymlload => :environment do
      Flextures::Rake::Command::ymlload
    end
  end
end
