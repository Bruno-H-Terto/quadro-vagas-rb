require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'jobs'
  add_filter 'mailers'
 end
