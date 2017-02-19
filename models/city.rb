class City
  attr_reader :location
  attr_reader :data

  def initialize(hsh)
    @data = hsh
  end

  def distance_to(loc)
    location.distance_to(loc)
  end

  def to_s
    "#{name} (#{self.class.name})"
  end

  def csc
    CscProviders.csc_for_city(self)
  end

  def provider_name
    self.class.name.split(/::/).first
  end
end
