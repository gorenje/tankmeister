class City
  attr_reader :location
  attr_reader :data

  def initialize(hsh)
    @data = hsh
  end

  def distance_to(loc)
    location.distance_to(loc)
  end
end
