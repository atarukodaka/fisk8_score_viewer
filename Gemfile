source 'https://rubygems.org'

# Padrino supports Ruby version 1.9 and later
# ruby '2.2.6'

# Distribute your app as a gem
# gemspec

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

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
  gem 'sqlite3'
end

group :production do   ## for heroku
  gem 'pg'
end

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.14.0.1'

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core support gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.14.0.1'
# end

gem 'pry-byebug'
gem 'pdftotext'
gem 'mechanize'
