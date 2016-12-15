class FuelStation
  attr_reader :location

  def initialize(hsh)
    @data = hsh
    @location = Geokit::LatLng.new(hsh["latitude"], hsh["longitude"])
  end

  def distance(car)
    location.distance_to(car.location)
  end

  def to_s
    @data.to_s
  end

  def json_location
    { "lat" => @data["latitude"], "lng" => @data["longitude"] }.to_json
  end

  def name
    @data["name"]
  end

  def details
    "%s<br>%s<br>%s<br>" % [@data["name"],
                            @data["address"].join(", "),
                            @data["organisation"]]
  end
end

class ElecroFS < FuelStation
  def marker_icon
    "/images/marker_icon_loading.png"
  end
end

class PetrolFS < FuelStation
  def marker_icon
    "/images/marker_icon_fueling.png"
  end
end
