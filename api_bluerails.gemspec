# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_bluerails/version'

Gem::Specification.new do |spec|
  spec.name = 'api_bluerails'
  spec.version = ApiBluerails::VERSION
  spec.authors = ['Manuel Dudda']
  spec.email = ['manueldudda@redpeppix.de']
  spec.summary = 'Tools for developing an API written in Rails with api blueprint documentation'
  spec.description = 'Tools for developing an API written in Rails with api blueprint documentation'
  spec.homepage = 'https://github.com/manuel84/api_bluerails'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'rails'

end