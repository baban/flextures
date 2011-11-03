# encoding: utf-8

namespace :db do
  namespace :flextures do
    #desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :dump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    #desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :csvdump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    #desc "Dump data to the test/fixtures/ directory. Use TABLE=table_name"
    task :ymldump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::yml(fmt) }
    end

    task :load => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Loader::load(fmt) }
    end

    task :csvload => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Loader::csv(fmt) }
    end

    task :ymlload => :environment do
      Flextures::ARGS::parse.each { |fmt| Flextures::Loader::yml(fmt) }
    end
  end
end
