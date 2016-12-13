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

def curlobj(urlstr)
  Curl::Easy.new.tap do |w|
    w.url = urlstr
    w.follow_location = true
    w.timeout = 10
    w.headers["Accept"]           = "application/json;v=1.7"
    w.headers["Proxy-Connection"] = "keep-alive"
    w.headers["Accept-Language"]  = "de-DE,de;q=0.8,en-US;q=0.6,en;q=0.4"
    w.headers["X-Api-Key"]        = "adf51226795afbc4e7575ccc124face7"
    w.headers["User-Agent"]       = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36"
    w.headers["X-Language"]       = "de"
    w.headers["Referer"]          = "https://de.drive-now.com/"
    w.headers["Accept-Encoding"]  = "gzip, deflate"
    w.headers["Content-Type"]     = "application/json"
    w.headers["Connection"]       = "keep-alive"
    w.headers["Host"]             = "api2.drive-now.com"
    w.headers["Origin"]           = "https://de.drive-now.com"
  end
end

class FuelStation
  attr_reader :location

  def initialize(hsh)
    @data = hsh
    @location = Geokit::LatLng.new(hsh["latitude"], hsh["longitude"])
  end

  def distance(car)
    location.distance_to(car.location)
  end

  def to_s
    @data.to_s
  end
end

class ElecroFS < FuelStation
end

class PetrolFS < FuelStation
end

class Car
  attr_reader :location

  def initialize(hsh)
    @data = hsh
    @location = Geokit::LatLng.new(hsh["latitude"], hsh["longitude"])
  end

  def is_electro?
    @data["fuelType"] == "E"
  end

  def to_s
    @data.to_s
  end
end

desc "Get cars"
task :cars do
  c = curlobj("https://api2.drive-now.com/cities/6099?expand=full")
  c.perform
  gz = Zlib::GzipReader.new(StringIO.new(c.body.to_s))
  data = JSON(gz.read)

  electro_stations = data["chargingStations"]["items"].map do |hsh|
    ElecroFS.new(hsh)
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
