lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flextures/version'

Gem::Specification.new do |spec|
  spec.name          = "flextures"
  spec.version       = Flextures::VERSION
  spec.authors       = ["baban"]
  spec.email         = ["babanba.n@gmail.com"]
  spec.summary       = %q{load and dump fixtures.}
  spec.description   = %q{load and dump fixtures.}
  spec.homepage      = "http://github.com/baban/flextures"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.4.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = ["test/unit/flextures_args_test.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"
  spec.add_dependency "smarter_csv"

  spec.add_development_dependency "bundler", "> 1.6"
  spec.add_development_dependency "rake"
end
