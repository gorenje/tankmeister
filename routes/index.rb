get '/' do
  case request.host.split(/\./).first
  when 'dn' then redirect_to_host("/cars?csc=dnw")
  when 'c2g' then redirect_to_host("/cars?csc=ctg")
  when 'all' then redirect_to_host("/cars?csc=all")
  else
    haml :geoloc
  end
end

get '/cars' do
  @ym_base_content = haml(:"_you_marker_info", :layout => false).to_json
  haml :cars
end
