module ViewHelpers
  def title
    str = case params[:csc]
          when "dnw" then "DriveNow"
          when "ctg" then "Car2Go"
          when "all" then "DriveNow & Car2Go"
          when "any" then "Closest"
          else "DriveNow"
          end
    "#{str} Cars"
  end

  def you_marker_car_sharing_company
    str = case params[:csc]
          when "dnw" then "DriveNow"
          when "ctg" then "Car2Go"
          when "all" then "DriveNow & Car2Go"
          when "any" then "Closest Car"
          else "DriveNow"
          end
    "Showing #{str}"
  end

  def map_car_details_to_result_hash(data, my_location, params)
    nearest_cars = if params[:csc] == 'any'
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
end
