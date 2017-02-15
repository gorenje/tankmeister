get '/city' do
  content_type :json

  klzs        = CscProviders.cities(params[:csc] || 'dnw')
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

  paras = {
    "id"  => params[:cid],
    "lat" => my_location.lat,
    "lng" => my_location.lng
  }

  lookupcsc = params[:csc] || 'dnw'

  cities = case lookupcsc
           when 'all', 'any'
             CscProviders.cities(lookupcsc).
               map { |klz| klz.send(:all).nearest(my_location).first }
           else
             CscProviders.cities(lookupcsc).map { |klz| klz.send(:new, paras) }
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

  tz = TzCache.lookup(params["lat"], params["lng"])

  { "cars"   => resp[0].map(&:to_hash),
    "fs"     => resp[1].map(&:to_hash),
    "tstamp" => tz.utc_to_local(DateTime.now).strftime("%H:%M:%S %d/%m/%Y")
  }.to_json
end

get '/standingtime' do
  content_type :json
  secs, mins, cdef, chtml =
    begin
      datastr = Curlobj.body("https://#{ENV['CARSTATS_HOST']}/" +
                             "standingtime?lp=" +
                             CGI::escape(params[:lp]))
      t = JSON(datastr)["time"]
      c = JSON(datastr)["cln"]
      [t.to_i, (t/60.0).ceil] + if c.last == 0
                                  [false, ""]
                                else
                                  [true, "<img src='/cleanliness/#{c.last}"+
                                   "/#{c.first}.svg' width='30px'/>"]
                                end
    rescue Exception => e
      ["...","...", false, ""]
    end

  { :time => {
      :seconds => secs,
      :minutes => mins
    },
    :cleanliness => {
      :defined => cdef,
      :html    => chtml
    }
  }.to_json
end

get '/color' do
  content_type :json
  clr = begin
          datastr = Curlobj.body("https://#{ENV['CARSTATS_HOST']}/"+
                                 "avgstime?lp="+CGI::escape(params[:lp]))
          t = JSON(datastr)["time"]
          st = params[:st].to_i
          st >= t ? "red" : (st < (t*0.50) ? "green" : "orange")
        rescue Exception => e
          "black"
        end

  { :color => clr }.to_json
end
