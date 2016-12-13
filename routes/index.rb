get '/' do
  c = Curlobj.prepare("https://api2.drive-now.com/cities/6099?expand=full")
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

  @center = { "lat" => data["latitude"], "lng" => data["longitude"] }

  @car = cars.first

  @fs = (@car.is_electro? ? electro_stations : petrol_stations).
    map { |a| [a, a.distance(@car)] }.sort_by { |_,dist| dist }[0..2].
    map { |fs,dist| fs }

  haml :index
end
