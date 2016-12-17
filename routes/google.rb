get '/google.js' do
  content_type "application/javascript"
  Curlobj.body("https://maps.googleapis.com/maps/api/js?key="+
               "#{ENV['GOOGLE_API_KEY']}&callback=initMap")
end
