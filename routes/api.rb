get '/city' do
  content_type :json

  klz = case (params[:csc] || 'dnw')
        when 'dnw' then DriveNow::City
        when 'ctg' then Car2Go::City
        else DriveNow::City
        end

  my_location = Geokit::LatLng.new(params["lat"].to_f, params["lng"].to_f)
  city        = klz.all.nearest(my_location).first

  { :cityid => CGI::escape(city.id), :name => city.name }.to_json
end

get '/nearest' do
  content_type :json

  city = case (params[:csc] || 'dnw')
         when 'dnw' then DriveNow::City.new("id" => params[:cid])
         when 'ctg' then Car2Go::City.new("locationName" => params[:cid])
         else DriveNow::City.new("id" => params[:cid])
         end

  data = city.car_details

  my_location = Geokit::LatLng.new(params["lat"].to_f, params["lng"].to_f)

  nearest_cars = data[:cars].
    select { |c| c.needs_fuelling? }.
    reject { |c| c.is_charging? }.
    nearest(my_location)[0..2]

  fuelstations = nearest_cars.map do |car|
    (car.is_electro? ? data[:electro_stations] : data[:petrol_stations]).
      nearest(car.location)[0..2]
  end.flatten

  { "cars" => nearest_cars.map(&:to_hash),
    "fs"   => fuelstations.map(&:to_hash)
  }.to_json
end
