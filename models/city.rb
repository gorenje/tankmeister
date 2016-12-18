class City
  attr_reader :location

  def self.all
    Curlobj.
      data_for("https://api2.drive-now.com/"+
               "cities?expand=cities")["items"].map do |hsh|
      City.new(hsh)
    end
  end

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

  def free_car_data
    Curlobj.data_for("https://api2.drive-now.com/cities/#{id}?expand=full")
  end
end
