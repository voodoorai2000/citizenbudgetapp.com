source 'https://rubygems.org'

ruby '1.9.3'
gem 'rails', '3.2.6'
gem 'rails-i18n'

group :production do
  # Error logging
  gem 'airbrake'
  gem 'heroku'

  # Performance
  gem 'dalli'
  gem 'newrelic_rpm'
end

# Background jobs
gem 'girl_friday'

# Database
gem 'mongoid', git: 'git://github.com/mongoid/mongoid.git', branch: '3.0.0-stable' # wait for 3.0.5

# Admin
gem 'formtastic', '2.2.1'
# 0.4.4 is buggy
gem 'activeadmin', git: 'git://github.com/gregbell/active_admin.git'
gem 'activeadmin-mongoid', '~> 0.0.2.jpmckinney.0'
gem 'cancan'
gem 'devise'
gem 'devise-i18n'
gem 'google-api-client', require: 'google/api_client'
gem 'mustache'

# Image uploads
gem 'fog'
gem 'rmagick'
# @see https://github.com/jnicklas/carrierwave-mongoid/pull/29#issuecomment-7249357
gem 'carrierwave-mongoid', git: 'git://github.com/jnicklas/carrierwave-mongoid.git', branch: 'mongoid-3.0'

# Views
gem 'haml-rails'
gem 'rdiscount'
gem 'unicode_utils'

# Export
gem 'spreadsheet'
gem 'axlsx'

# Heroku API
gem 'oj'
gem 'multi_json'
gem 'faraday'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# For maintenance scripts to run in development console.
group :development do
  gem 'mechanize'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.6'
end

gem 'unicorn'
