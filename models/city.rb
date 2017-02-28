class City
  attr_reader :location
  attr_reader :data

  EmptyCarDetails = {
    :electro_stations => [],
    :cars             => [],
    :petrol_stations  => []
  }

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

  def car_details
    obtain_car_details
  rescue Exception => e
    puts "Exception for #{self.class.name} City: #{id} / #{name}"
    puts e
    puts e.backtrace
    EmptyCarDetails
  end
end
