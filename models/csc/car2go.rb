module Car2Go
  class Car < Car
    def initialize(hsh)
      super(hsh)
      crds = @data["coordinates"]
      @location = Geokit::LatLng.new(crds[1],crds[0])
      @data["fuelType"] = "PE10" # only applies if non-electro
    end

    def is_electro?
      @data["engineType"] == "ED"
    end

    def name
      @data["name"]
    end

    def needs_fuelling?
      @data["fuel"] <= 20
    end

    def is_charging?
      !!@data["charging"]
    end

    def address_line
      @data["address"]
    end

    def marker_icon
      "/images/marker_car2go_car.svg"
    end

    def vin
      @data["vin"]
    end

    def image_url
      "/images/c2g/#{URI::escape(@data["city_location"])}/#{URI::escape(vin)}"
    end

    def latlng
      [location.lat, location.lng].join(",")
    end

    def reserve_url
      "car2go://car2go.com/vehicle/%s?latlng=%s" % [ vin, latlng ]
    end

    def fuel_in_percent
      @data["fuel"]
    end

    def license_plate
      @data["name"]
    end

    def cleanliness
      @data["interior"] == "GOOD" ? "2/2" : "2/1"
    end
  end

  class PetrolFS < PetrolFS
    def initialize(hsh)
      org, addr = hsh["name"].split(/,/).map(&:strip)
      hsh["latitude"]     = hsh["coordinates"][1]
      hsh["longitude"]    = hsh["coordinates"][0]
      hsh["name"]         = org
      hsh["address"]      = [addr]
      hsh["organisation"] = org
      super(hsh)
    end

    def marker_icon
      "/images/station/c2g/petrol/marker.svg"
    end
  end

  class ElectroFS < ElectroFS
    def initialize(hsh)
      hsh["latitude"]  = hsh["coordinates"][1]
      hsh["longitude"] = hsh["coordinates"][0]
      hsh["address"]   = [hsh["name"]]
      hsh["name"]      = "-"
      super(hsh)
    end

    def marker_icon
      "/images/station/c2g/electro/"+(is_crowded? ? "crowded" : "empty")+".svg"
    end

    def capacity_info
      used,total = ["usedCapacity","totalCapacity"].map{|a|@data[a]}.map(&:to_i)
      { :free => total - used, :total => total }
    end
  end


  class City < City
    def self.image_details(loc)
      City.mechanize_agent.
        json("https://www.car2go.com/caba/customer/vehicles/"+
             "#{URI::escape(loc)}?oauth_consumer_key="+
             "#{ENV['CAR2GO_CONSUMER_KEY']}&format=json")["vehicle"]
    end

    def self.image_url_for(loc,vin)
      car_details = image_details(loc).select { |car| car["vin"] == vin}.first

      if car_details.nil?
        "public/images/transparent.png"
      else
        lky = car_details["secondaryColor"] || car_details["primaryColor"]
        clr = Car2GoColorLookup[lky[0..2]]
        age = Car2GoHardwareLookup[car_details["hardwareVersion"]] || ""
        mdl = Car2GoModelLookup[car_details["model"]]
        "public/images/car2go/#{mdl}_#{age}#{clr}.png"
      end
    end

    def self.all
      mechanize_agent.
        json("https://www.car2go.com/api/v2.1/locations?"+
             "oauth_consumer_key=#{ENV['CAR2GO_CONSUMER_KEY']}"+
             "&format=json")["location"].map do |hsh|
        Car2Go::City.new(hsh)
      end
    end

    def initialize(hsh)
      hsh["locationName"] = hsh["id"] if hsh["id"]
      super(hsh)
      loc = @data["mapSection"]["center"] rescue {}
      @location = Geokit::LatLng.new(loc["latitude"], loc["longitude"])
    end

    def name
      "%s, %s" % [ @data["locationName"], @data["countryCode"] ]
    end

    def id
      data["locationName"]
    end

    def obtain_car_details
      {}.tap do |resp|
        resp[:cars] = City.mechanize_agent.
          json("https://www.car2go.com/api/v2.1/vehicles"+
               "?oauth_consumer_key=#{ENV['CAR2GO_CONSUMER_KEY']}"+
               "&format=json&loc=" +
               CGI::escape(id))["placemarks"].map do |hsh|
          hsh.merge!("city_location" => id)
          Car2Go::Car.new(hsh)
        end

        resp[:electro_stations] = City.mechanize_agent.
          json("https://www.car2go.com/api/v2.1/parkingspots"+
               "?oauth_consumer_key=#{ENV['CAR2GO_CONSUMER_KEY']}"+
               "&format=json&loc=" +
               CGI::escape(id))["placemarks"].
          select { |hsh| hsh["chargingPole"] }.
          map do |hsh|
          Car2Go::ElectroFS.new(hsh)
        end

        resp[:petrol_stations] = City.mechanize_agent.
          json("https://www.car2go.com/api/v2.1/gasstations"+
               "?oauth_consumer_key=#{ENV['CAR2GO_CONSUMER_KEY']}"+
               "&format=json&loc=" +
               CGI::escape(id))["placemarks"].map do |hsh|
          Car2Go::PetrolFS.new(hsh)
        end
      end
    end
  end
end

CscProviders.register("ctg", "Car2Go", Car2Go::City)
