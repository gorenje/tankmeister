class City
  attr_reader :location
  attr_reader :data

  EmptyCarDetails = {
    :electro_stations => [],
    :cars             => [],
    :petrol_stations  => []
  }

  module ExtendWithJson
    def json(*args)
      JSON(get(*args).body)
    end

    def jpost(url, data)
      JSON(post(url,data).body)
    end
  end

  def self.mechanize_agent(user_agent = :use_mozilla)
    Mechanize.new.tap do |agent|
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      if user_agent == :use_mozilla
        agent.user_agent_alias = 'Linux Mozilla'
      else
        agent.user_agent = user_agent
      end
    end.send(:extend, City::ExtendWithJson)
  end

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
