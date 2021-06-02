lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prioritized_callbacks/version'

Gem::Specification.new do |s|
  s.name          = 'prioritized_callbacks'
  s.version       = PrioritizedCallbacks::VERSION
  s.summary       = "Prioritizing ActiveSupport::Callbacks"
  s.description   = "This gem allows to define a custom order in which callbacks are called"
  s.authors       = ["Anton Argirov"]
  s.email         = 'anton.argirov@gmail.com'
  s.homepage      = 'https://github.com/anteo/prioritized_callbacks'
  s.license       = 'MIT'
  s.files         = Dir.glob("{gemfiles,lib,spec}/**/*") + %w(.rspec Appraisals Gemfile LICENSE.txt prioritized_callbacks.gemspec Rakefile README.md)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', ['>=5.0']

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'appraisal'
end