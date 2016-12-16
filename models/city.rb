class City
  attr_reader :location

  def initialize(hsh)
    @data = hsh
    @location = Geokit::LatLng.new(hsh["latitude"], hsh["longitude"])
  end

  def id
    @data["id"]
  end

  def distance(loc)
    @location.distance_to(loc)
  end

  def name
    "%s, %s" % [@data["name"], @data["countryLabel"]]
  end
end
