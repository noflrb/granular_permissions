# -*- encoding: utf-8 -*-
require File.expand_path("../lib/granular_permissions/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "granular_permissions"
  s.version = GranularPermissions::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Bernardo Telles"]
  s.email = ["btelles@gmail.com"]
  s.homepage = "http://github.com/noflrb/granular_permissions"
  s.summary = "Rails 3 Granular Permissions"
  s.description = "Set 'require' and 'available' permissions on specific to columns in any model."

  s.required_rubygems_version = ">= 1.7.2"

  s.add_dependency "activerecord", "~> 3.0.0"
  s.add_dependency "activesupport", "~> 3.0.0"
  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rspec", "~> 2.5.0"
  s.add_development_dependency "database_cleaner", "0.5.2"
  s.add_development_dependency "sqlite3-ruby", "~> 1.3.0"
  s.add_development_dependency "generator_spec", "~> 0.8.2"
  s.add_development_dependency "cucumber", "~> 0.10.0"
  s.add_development_dependency "capybara-webkit", "~> 0.2.0"
  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "jeweler", "~> 1.5.2"
  s.add_development_dependency "rcov", ">= 0"
  s.add_development_dependency "reek", "~> 1.2.8"
  s.add_development_dependency "roodi", "~> 2.1.0"

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
