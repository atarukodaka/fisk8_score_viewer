source 'https://rubygems.org'

# Padrino supports Ruby version 2.1 and later (using Array.to_h)
ruby '>=2.1'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'activesupport', '>= 3.1'
gem 'bcrypt'
gem 'erubi', '~> 1.6'
gem 'activerecord', '>= 3.1', :require => 'active_record'

group :development, :test do
  gem 'pry-byebug'
  gem 'sqlite3'
end

group :production do   ## for heroku
  gem 'pg'
end

# Test requirements
gem 'rspec', :group => 'test'
gem 'rspec-its', :group => 'test'
gem 'rack-test', :require => 'rack/test', :group => 'test'

# Padrino Stable Gem
gem 'padrino', '0.14.0.1'

# Additional Gems
gem 'pdftotext'
gem 'mechanize'
