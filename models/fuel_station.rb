class FuelStation
  attr_reader :location

  def initialize(hsh)
    @data = hsh
    @location = Geokit::LatLng.new(hsh["latitude"], hsh["longitude"])
  end

  def distance(loc)
    location.distance_to(loc)
  end

  def to_s
    @data.to_s
  end

  def json_location
    { "lat" => location.lat, "lng" => location.lng }
  end

  def name
    @data["name"]
  end

  def organisation
    @data["organisation"]
  end

  def address_line
    @data["address"].join(", ")
  end

  def details
    Haml::Engine.new(File.read(File.dirname(__FILE__)+
                               "/../views/_fs_details.haml")).
      render(binding)
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

class ElectroFS < FuelStation
  def marker_icon
    "/images/marker_icon_loading.png"
  end
end

class PetrolFS < FuelStation
  def marker_icon
    "/images/marker_icon_fueling.png"
  end
end
