get '/' do
  redirect("https://#{request.host}") if redirect_host_to_ssl?
  haml :index
end

get '/cars' do
  redirect '/'
end
