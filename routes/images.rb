get '/images/cleanliness/4/:value.svg' do
  content_type "image/svg+xml"
  @clrs = case params[:value]
          when "1" then ["ea1f24", "ffffff", "ffffff","ffffff"]
          when "2" then ["ea1f24", "cb920a", "ffffff","ffffff"]
          when "3" then ["ea1f24", "cb920a", "c6ea1f","ffffff"]
          when "4" then ["ea1f24", "cb920a", "c6ea1f","13fd0d"]
          else
            ["ffffff", "ffffff", "ffffff","ffffff"]
          end
  haml :"images/_cleanliness4.svg", :layout => false
end

get '/images/cleanliness/2/:value.svg' do
  content_type "image/svg+xml"
  @clrs = case params[:value]
          when "1" then ["ea1f24", "ffffff"]
          when "2" then ["ea1f24", "cb920a"]
          else
            ["ffffff", "ffffff"]
          end
  haml :"images/_cleanliness2.svg", :layout => false
end

get '/images/car/drivenow/:type.svg' do
  content_type "image/svg+xml"
  @fillclr = params[:type] == "electro" ? "86b80e" : "005c7d"
  haml :"images/_drive_now_car.svg", :layout => false
end
