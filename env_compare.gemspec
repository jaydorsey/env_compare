# frozen_string_literal: true

require_relative 'lib/env_compare/version'

Gem::Specification.new do |spec|
  spec.name = 'env_compare'
  spec.version = EnvCompare::VERSION
  spec.authors = ['Jay Dorsey']
  spec.email = ['jaydorsey@fastmail.com']

  spec.summary = 'Compare ENV variables across Heroku environments'
  spec.description = 'Compare ENV variables across Heroku environments'
  spec.homepage = 'https://jaydorsey.com/'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jaydorsey/env_compare'
  spec.metadata['changelog_uri'] = 'https://github.com/jaydorsey/env_compare/blob/master/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'launchy'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
end
