source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 7.1.1"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# gem 'sass-rails', '~> 5.0'
# gem 'uglifier', '>= 1.3.0'

# gem 'jquery-rails'
# gem 'jquery-ui-rails'
gem 'jbuilder', '~> 2.5'
gem 'bootstrap', '~> 5.2.0'

gem 'devise'
gem 'high_voltage'
gem 'simple_form'
gem 'rest-client'
gem 'nokogiri'
gem 'cocoon'
gem 'will_paginate', '~> 3.3'
gem 'ransack', :github => 'activerecord-hackery/ransack', :branch => 'main'
gem 'roo'
gem 'roo-xls'
gem 'figaro'
gem 'whenever', require: false
gem 'pg'
# gem 'unicorn'
gem 'phonelib'
gem 'image_processing'
gem 'active_storage_validations'
gem 'ru_propisju'
# gem 'rails-jquery-autocomplete'
gem 'daemons'
# gem 'delayed_job_active_record'
gem 'cancancan'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'rubyzip'
gem 'rack-protection'

gem "sidekiq"
gem "bootsnap", require: false


gem 'bcrypt_pbkdf', '< 2.0', :require => false
gem 'ed25519', '~> 1.2', '>= 1.2.4'

group :development do
  gem "capistrano", require: false
  gem "capistrano-rails", require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-rails-console'
  gem 'capistrano-sidekiq'


  gem 'web-console', '>= 3.3.0'
  # gem 'listen'
  # gem 'spring'
end

group :development, :test do
  gem 'byebug', platform: :mri
end
