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
  #gem 'bullet'
  #gem 'stackprof', git: "git://github.com/tmm1/stackprof.git", branch: "master"
  #gem 'benchmark'
  
end

group :production do   ## for heroku
  gem 'pg'
end

# Test requirements
group :test do 
  gem 'rspec'
  gem 'rspec-its'
  gem 'rack-test', :require => 'rack/test'
  gem 'hashie'
end

# Padrino Stable Gem
gem 'padrino', '0.14.0.1'

# Additional Gems
gem 'pdftotext'
gem 'mechanize'
