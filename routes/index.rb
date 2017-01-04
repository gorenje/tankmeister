get '/' do
  redirect("https://#{request.host}") if redirect_host_to_ssl?
  haml :index
end

get '/cars' do
  @ym_base_content = haml(:"_you_marker_info", :layout => false).to_json
  haml :cars
end
