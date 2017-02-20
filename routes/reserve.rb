get '/reserve/*' do
  redirect Base64.decode64(request.path.gsub(/^\/reserve\//,''))
end
