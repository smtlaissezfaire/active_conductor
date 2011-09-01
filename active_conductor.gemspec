# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'active_conductor'
  s.version     = '0.2.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Scott Taylor', 'Michael Kessler']
  s.email       = ['scott@railsnewbie.com', 'michi@netzpiraten.ch']
  s.homepage    = 'https://github.com/smtlaissezfaire/active_conductor'
  s.summary     = 'Conductor plugin for Rails 3'
  s.description = 'This plugin uses the conductor pattern to wrap multiple models as one object'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = 'active_conductor'

  s.add_dependency 'activemodel', '>= 3.0.0'

  s.add_development_dependency 'bundler',       '~> 1.0.18'
  s.add_development_dependency 'guard',         '~> 0.6.2'
  s.add_development_dependency 'guard-rspec',   '~> 0.4.2'
  s.add_development_dependency 'rspec',         '~> 2.6.0'
  s.add_development_dependency 'activerecord',  '~> 3.1.0'
  s.add_development_dependency 'sqlite3-ruby',  '~> 1.3.3'
  s.add_development_dependency 'yard',          '~> 0.7.2'
  s.add_development_dependency 'bluecloth',     '~> 2.0.11'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE.txt README.md]
  s.require_path = 'lib'
end
