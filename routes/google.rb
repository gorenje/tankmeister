get '/j/google.js' do
  content_type "application/javascript"
  City.mechanize_agent.
    get("https://maps.googleapis.com/maps/api/js?key="+
        "#{ENV['GOOGLE_API_KEY']}&callback=initMap").body
end

get '/serviceWorker.js' do
  content_type "application/javascript"
  File.read('public/j/serviceWorker.js')
end
