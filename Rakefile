# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "flextures"
  gem.homepage = "http://github.com/baban/flextures"
  gem.license = "MIT"
  gem.summary = %Q{load and dump fixtures}
  gem.description = %Q{load and dump fixtures}
  gem.email = "babanba.n@gmail.com"
  gem.authors = ["baban"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "flextures #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options = ["--charset", "utf-8", "--line-numbers"] 
end

namespace :db do
  namespace :flextures do
    desc "Load fixture datas fixtures directory"
    task :load => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Loader::load(fmt) }
    end

    desc "Load fixture datas fixtures directory onlu csv file"
    task :csvload => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Loader::csv(fmt) }
    end

    desc "Load fixture datas fixtures directory onlu yaml file"
    task :ymlload => :environment do
      Flextures::ARGS::parse.each { |fmt| Flextures::Loader::yml(fmt) }
    end

    desc "Dump data to the fixtures directory"
    task :dump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    desc "Dump data to the fixtures directory csv format"
    task :csvdump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::csv(fmt) }
    end

    desc "Dump data to the fixtures directory yaml format"
    task :ymldump => :environment do
      Flextures::ARGS.parse.each { |fmt| Flextures::Dumper::yml(fmt) }
    end

  end
end

