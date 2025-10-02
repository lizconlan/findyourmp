source "https://rubygems.org"

gem 'rake', '10.1.0'
gem 'rails', '2.3.17'
gem 'rdoc'
gem 'haml', '3.1.8'
gem 'authlogic', '2.1.10'
gem 'friendly_id', '2.3.4', :require => "friendly_id"
gem 'xss_terminate'
gem 'hpricot'
# Support both modern host (Ruby >= 2.3) and legacy Docker (Ruby 1.9.3)
if RUBY_VERSION < '2.0'
  gem 'nokogiri', '1.6.1'
else
  gem 'nokogiri', '~> 1.10.10'
end
gem 'aws-s3'
gem 'mysql2', '0.2.6'
# Fallback legacy adapter for environments where mysql2 0.2.x is incompatible
# with modern libmysqlclient; used by docker-compose dev setup
gem 'mysql', '~> 2.9.1'
gem 'unicode'
gem 'resource_controller'
gem 'rest-client'
# Constrain unf for Ruby 1.9.3 compatibility (avoid unf >= 0.2 requiring Ruby >= 2.2)
gem 'unf', '< 0.2.0'
gem 'newrelic_rpm'

group :test do
  gem 'test-unit', '1.2.3'
gem 'webrat'
# Override ffi for compatibility with Ruby 2.3 and modern macOS toolchains
gem 'ffi', '~> 1.9.25'
  gem 'simplecov'
  gem 'rspec', '1.3.2'
  gem 'rspec-rails', '1.3.2'
  gem "capybara", "1.1.1"
  gem "gherkin", "2.5.0"
  gem 'json', '~> 1.8.6'
  gem 'cucumber', '1.1.0'
  gem 'cucumber-rails', '0.3.2'
end

group :development do
  gem 'capistrano', '2.15.5'
  gem 'rvm-capistrano'
  gem 'net-ssh', '2.7.0'
end
