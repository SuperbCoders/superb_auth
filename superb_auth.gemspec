$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'superb_auth/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'superb_auth'
  s.version     = SuperbAuth::VERSION
  s.authors     = ['Alexander Borovykh']
  s.email       = ['immaculate.pine@gmail.com']
  s.homepage    = ''
  s.summary     = 'Ruby gem that adds Devise authentication and OmniAuth support'
  s.description = 'Ruby gem that adds Devise authentication and OmniAuth support'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.1.5'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
end
