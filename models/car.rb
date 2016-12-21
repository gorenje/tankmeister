class Car
  attr_reader :location

  def initialize(hsh)
    @data = hsh
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

  def details
    Haml::Engine.new(File.read(File.dirname(__FILE__)+
                               "/../views/_car_details.haml")).
      render(binding)
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
