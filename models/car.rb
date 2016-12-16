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
    { "lat" => @data["latitude"], "lng" => @data["longitude"] }
  end

  def distance(loc)
    @location.distance_to(loc)
  end

  def to_s
    @data.to_s
  end

  def name
    "%s (%s)" % [@data["licensePlate"], @data["name"]]
  end

  def needs_fuelling?
    @data["fuelLevel"] <= 0.25
  end

  def is_charging?
    @data["isCharging"]
  end

  def address_line
    @data["address"].join(", ")
  end

  def image_url
    @data["carImageUrl"].gsub(/\{density\}/, "hdpi")
  end

  def marker_icon
    "/images/" + (is_electro? ? "marker_icon_car_active" : "marker_icon_car") +
      ".png"
  end

  def reserve_url
    # this will open the drive now app but not much else.
    "drivenow://car?id=#{@data["id"]}"
  end

  def details
    "<img src='#{image_url}'/><p>" +
      "#{name}<br>" +
      "#{address_line}<br>" +
      "Fuel level: #{@data["fuelLevelInPercent"]}%<br>" +
      "<a href='#{reserve_url}'>Reserve</a>"
  end

  def to_hash
    {
      "details"       => details,
      "marker_icon"   => marker_icon,
      "name"          => name,
      "json_location" => json_location
    }
  end
end
