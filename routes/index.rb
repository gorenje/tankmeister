get '/' do
  haml :geoloc
end

get '/cars' do
  @ym_base_content = haml(:"_you_marker_info", :layout => false).to_json
  haml :cars
end
