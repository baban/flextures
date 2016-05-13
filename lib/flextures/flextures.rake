require 'flextures/flextures'

namespace :db do
  namespace :flextures do
    desc "Dump data to csv format"
    task :dump => :environment do
      Flextures::Rake::Command::dump
    end

    desc "load fixture data csv format"
    task :load => :environment do
      Flextures::Rake::Command::load
    end

    desc "load and dump file (replace) new data file"
    task :generate => :environment do
      Flextures::Rake::Command::generate
    end
  end
end
