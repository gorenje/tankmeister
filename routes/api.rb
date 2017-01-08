get '/city' do
  content_type :json

  klzs = case (params[:csc] || 'dnw')
         when 'mcy' then [Multicity::City]
         when 'dnw' then [DriveNow::City]
         when 'ctg' then [Car2Go::City]
         when 'all', 'any' then [DriveNow::City, Car2Go::City, Multicity::City]
         else [DriveNow::City]
         end

  my_location = Geokit::LatLng.new(params["lat"].to_f, params["lng"].to_f)
  city        = klzs.map(&:all).flatten.nearest(my_location).first

  { :cityid          => CGI::escape(city.id),
    :name            => city.name,
    :ym_base_content => haml(:"_you_marker_info", :layout => false)
  }.to_json
end

get '/nearest' do
  content_type :json

  my_location = Geokit::LatLng.new(params["lat"].to_f, params["lng"].to_f)

  cities = case (params[:csc] || 'dnw')
           when 'mcy'
             paras = {
               "id"  => params[:cid],
               "lat" => my_location.lat,
               "lng" => my_location.lng
             }
             [Multicity::City.new(paras)]
           when 'dnw' then [DriveNow::City.new("id" => params[:cid])]
           when 'ctg' then [Car2Go::City.new("locationName" => params[:cid])]
           when 'all', 'any'
             [DriveNow::City.all.nearest(my_location).first,
              Car2Go::City.all.nearest(my_location).first,
              Multicity::City.all.nearest(my_location).first
             ]
           else [DriveNow::City.new("id" => params[:cid])]
           end

  resp = cities.map do |city|
    map_car_details_to_result_hash(city.car_details, my_location, params)
  end.map do |rs|
    [ rs["cars"], rs["fs"] ]
  end.inject( [[],[]] ) do |result, ary|
    result[0] += ary.first
    result[1] += ary.last
    result
  end

  tz = Timezone.lookup(params["lat"], params["lng"])

  { "cars"   => resp[0].map(&:to_hash),
    "fs"     => resp[1].map(&:to_hash),
    "tstamp" => tz.utc_to_local(DateTime.now).strftime("%H:%M:%S %d/%m/%Y")
  }.to_json
end
