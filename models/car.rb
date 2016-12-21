# Since DriveNow was here first, this Car model assumes DriveNow structured
# data. Car2Go redefines this class to make it work for its data structure.
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
    { "lat" => location.lat, "lng" => location.lng }
  end

  def distance(loc)
    location.distance_to(loc)
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
    "/images/marker_icon_car.png"
  end

  def reserve_url
    # this will open the drive now app but not much else.
    "drivenow://car?id=#{@data["id"]}"
  end

  def fuel_in_percent
    @data["fuelLevelInPercent"]
  end

  def details
    require 'haml'
    engine = Haml::Engine.new(File.read(File.dirname(__FILE__)+
                                        "/../views/_car_details.haml"))
    engine.render(binding)
  end

  def fuel_type
    is_electro? ? "Electro" : (@data["fuelType"] == "P" ? "Super" : "Diesel")
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
