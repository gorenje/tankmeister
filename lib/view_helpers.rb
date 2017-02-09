module ViewHelpers
  def you_marker_car_sharing_company
    "Showing #{CscProviders.name(params[:csc])}"
  end

  def map_car_details_to_result_hash(data, my_location, params)
    nearest_cars = if params[:csc] == 'any' || params[:csc] =~ /_available/
                     data[:cars]
                   else
                     data[:cars].
                       select { |c| c.needs_fuelling? }.
                       reject { |c| c.is_charging? }
                   end.nearest(my_location)[0..2]

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
end
