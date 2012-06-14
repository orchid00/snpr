source 'http://rubygems.org'

gem 'rails', '3.0.10'
gem 'authlogic' # lots of user-related magic
gem 'rails3-generators'
gem "jquery-rails"
gem 'bartt-ssl_requirement', '~>1.4.0', :require => 'ssl_requirement'
gem 'vegas'
gem 'bcrypt-ruby', :require => "bcrypt"

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3'
# use postgresql instead:
gem 'pg', :require => 'pg'

# for solr (indexing, searching)
gem 'sunspot_rails', '~> 1.2.1'

# so we can create zip-files for genotypes
gem 'rubyzip','0.9.5', :require => 'zip/zip'

# for jobs
gem 'resque' 
gem 'resque-loner'

gem "will_paginate", "3.0.pre2" # needed for Rails 3, pagination
gem 'nested_form', :git => 'https://github.com/ryanb/nested_form.git'
gem 'json'
gem 'mediawiki-gateway'
gem 'activerecord-import'
gem 'paperclip', '~> 2.4'
gem 'friendly_id', :git => 'https://github.com/norman/friendly_id.git'
gem 'recommendify', :git => 'https://github.com/paulasmuth/recommendify.git'

#group :production do
#	gem 'rpm_contrib'
#	gem 'newrelic_rpm'
#end


#group :development do
#  gem 'rcov_rails'
#end

group :test do
  gem 'shoulda-context'
  gem 'shoulda-matchers'
  gem 'factory_girl'
  gem 'mocha'
  gem 'ruby-debug19'
  gem 'sunspot_test'
end

# gem 'email_veracity' # to check whether user-mails are OK
# authlogic does that anyway

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
# gem 'webrat'
# end
