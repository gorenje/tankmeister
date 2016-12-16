get '/' do
  haml :geoloc
end

post '/cars' do
  data = Curlobj.
    data_for("https://api2.drive-now.com/cities?expand=cities")

  my_location = Geokit::LatLng.new(params["lat"].to_f, params["lng"].to_f)

  @city = data["items"].map { |hsh| City.new(hsh) }.nearest(my_location).first

  haml :cars
end

get '/nearest' do
  content_type :json

  data = Curlobj.
    data_for("https://api2.drive-now.com/cities/#{params[:cid]}?expand=full")

  electro_stations = data["chargingStations"]["items"].map do |hsh|
    ElecroFS.new(hsh)
  end

  petrol_stations = data["petrolStations"]["items"].map do |hsh|
    PetrolFS.new(hsh)
  end

  cars = data["cars"]["items"].map { |hsh| Car.new(hsh) }.
    select { |c| c.needs_fuelling? }.
    reject { |c| c.is_charging? }

  my_location = Geokit::LatLng.new(params["lat"].to_f, params["lng"].to_f)

  nearest_cars = cars.nearest(my_location)[0..2]

  fuelstations = []
  nearest_cars.map do |car|
    fuelstations +=
      (car.is_electro? ? electro_stations : petrol_stations).
      nearest(car.location)[0..2]
  end

  { "cars" => nearest_cars.map(&:to_hash),
    "fs"   => fuelstations.map(&:to_hash)
  }.to_json
end
