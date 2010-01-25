require 'rubygems'
gem 'activesupport', '~> 2.3.0'
gem 'activerecord', '~> 2.3.0'
gem 'rspec', '~> 1.2.0'

require 'active_record'
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
