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

desc "Get cars"
task :cars do
  c = Curlobj.prepare("https://api2.drive-now.com/cities/6099?expand=full")
  c.perform
  gz = Zlib::GzipReader.new(StringIO.new(c.body.to_s))
  data = JSON(gz.read)

  electro_stations = data["chargingStations"]["items"].map do |hsh|
    ElectroFS.new(hsh)
  end

  petrol_stations = data["petrolStations"]["items"].map do |hsh|
    PetrolFS.new(hsh)
  end

  cars = data["cars"]["items"].select { |car| car["fuelLevel"] <= 0.25 }.
    map do |d|
    Car.new(d)
  end

  cars.select { |c| c.is_electro? }.each do |car|
    puts "==================="
    puts car
    puts electro_stations.map { |a| [a, a.distance(car)] }.
      sort_by { |a| a.last }[0..2]
  end

  cars.reject { |c| c.is_electro? }.each do |car|
    puts "==================="
    puts car
    puts petrol_stations.map { |a| [a, a.distance(car)] }.
      sort_by { |a| a.last }[0..2]
  end
end

desc "Start a pry shell and load all gems"
task :shell  do
  require 'pry'
  Pry.editor = ENV['PRY_EDITOR'] || ENV['EDITOR'] || 'emacs'
  Pry.start
end
