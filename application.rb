require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/streaming'
require 'sinatra/reloader'
require 'cgi'
require 'json'
require 'digest/md5'
require 'curb'
require 'zlib'
require 'stringio'
require 'geokit'
require 'haml'

if File.exists?(".env")
  require 'dotenv'
  Dotenv.load
end

# RAILS_ENV is set via unicorn in production and used
# by test_helper to also set the environment.
set(:environment,   ENV['RACK_ENV']) unless ENV['RACK_ENV'].nil?
set :server,        :thin
set :port,          (ENV['PORT'] || 2343).to_i
set :public_folder, Proc.new { File.join(root, "public") }
set :logging, true

set :raise_errors, true
set :show_exceptions, false
set :dump_errors, true

if settings.environment == :development
  require 'pry'
end

[
 ['routes'],
 ['models'],
 ['lib'],
].each do |path|
  Dir[File.join(File.dirname(__FILE__), path, '*.rb')].each { |f| require f }
end

helpers do
  include ViewHelpers
end
