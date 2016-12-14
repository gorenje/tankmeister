class Car
  attr_reader :location

  def initialize(hsh)
    @data = hsh
    @location = Geokit::LatLng.new(hsh["latitude"], hsh["longitude"])
  end

  def is_electro?
    @data["fuelType"] == "E"
  end

  def json_location
    { "lat" => @data["latitude"], "lng" => @data["longitude"] }.to_json
  end

  def distance(loc)
    @location.distance_to(loc)
  end

  def to_s
    @data.to_s
  end

  def name
    @data["licensePlate"]
  end

  def marker_icon
    "/images/" + (is_electro? ? "marker_icon_car_active" : "marker_icon_car") +
      ".png"
  end
end
