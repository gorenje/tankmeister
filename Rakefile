require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/testtask'
require 'curb'
require 'zlib'
require 'stringio'
require 'pry'
require 'json'
require 'geokit'

if File.exists?(".env")
  require 'dotenv'
  Dotenv.load
end

Dir[File.join(File.dirname(__FILE__), 'lib', 'tasks','*.rake')].each do |f|
  load f
end

[
 ['models'],
 ['lib'],
].each do |path|
  Dir[File.join(File.dirname(__FILE__), path, '*.rb')].each { |f| require f }
end
