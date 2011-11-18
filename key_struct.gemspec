# -*- encoding: utf-8 -*-
require File.expand_path('../lib/key_struct/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["ronen barzel"]
  gem.email         = ["ronen@barzel.org"]
  gem.description   = %q{Defines KeyStruct analogous to Struct, but constructor takes keyword arguments}
  gem.summary       = %q{Defines KeyStruct analogous to Struct, but constructor takes keyword arguments}
  gem.homepage      = 'http://github.com/ronen/key_struct'
  gem.extra_rdoc_files = [
    'LICENSE',
    'README.rdoc',
  ]

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "key_struct"
  gem.require_paths = ["lib"]
  gem.version       = KeyStruct::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'simplecov-gem-adapter'
end
