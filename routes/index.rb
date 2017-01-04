get '/' do
  if request.scheme == 'http' && request.host != 'localhost'
    redirect "https://#{request.host}"
  end

  haml :index
end

get '/cars' do
  @ym_base_content = haml(:"_you_marker_info", :layout => false).to_json
  haml :cars
end
