# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ratatouille/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "ratatouille"
  gem.version       = Ratatouille::VERSION
  gem.authors       = ["Ryan Johnson"]
  gem.email         = ["rhino.citguy@gmail.com"]
  gem.homepage      = "http://github.com/CITguy/#{gem.name}"
  gem.summary       = %q{DSL for validating complex hashes}
  gem.description   = %q{DSL for validating complex hashes}

  gem.rubyforge_project = 'ratatouille'

  gem.add_development_dependency "rspec", ">= 2.4.0"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "autotest"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
