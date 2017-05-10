module ViewHelpers
  def you_marker_car_sharing_company
    "Showing #{CscProviders.name(params[:csc])}"
  end

  def generate_svg(name, &block)
    content_type "image/svg+xml"
    yield if block_given?
    haml :"images/_#{name}.svg", :layout => false
  end

  def map_car_details_to_result_hash(data, my_location, params)
    lmt = (params[:lmt] || 3).to_i - 1
    lmt = lmt > 8 ? 8 : (lmt < 0 ? 2 : lmt)

    nearest_cars = if params[:csc] =~ /_available/
                     data[:cars]
                   else
                     data[:cars].
                       select { |c| c.needs_fuelling? }.
                       reject { |c| c.is_charging? }
                   end.nearest(my_location)[0..lmt]

    fuelstations = nearest_cars.map do |car|
      (car.is_electro? ? data[:electro_stations] : data[:petrol_stations]).
        nearest(car.location)[0..2]
    end.flatten

    { "cars" => nearest_cars.map(&:to_hash),
      "fs"   => fuelstations.map(&:to_hash)}
  end

  def redirect_host_to_ssl?
    request.scheme == 'http' &&
      !ENV['HOSTS_WITH_NO_SSL'].split(",").map(&:strip).include?(request.host)
  end

  def http_fallback(url)
    begin
      City.mechanize_agent.json(url)
    rescue => e
      City.mechanize_agent.json(url.sub(/^https/,"http"))
    end
  end
end
