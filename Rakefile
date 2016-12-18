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

[
 ['models'],
 ['lib'],
].each do |path|
  Dir[File.join(File.dirname(__FILE__), path, '*.rb')].each { |f| require f }
end

desc "Show free cars across the global"
task :current_free_count do
  City.all.each do |city|
    puts "%s: %d" % [ city.name, city.free_car_data["cars"]["count"] ]
  end
end

desc "Start a pry shell and load all gems"
task :shell  do
  require 'pry'
  Pry.editor = ENV['PRY_EDITOR'] || ENV['EDITOR'] || 'emacs'
  Pry.start
end
