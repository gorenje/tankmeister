module Multicity
  class Car < Car
    def initialize(hsh)
      super(hsh)
      @vehicle  = @data["value"]["vehicle"]
      loc       = @data["location"]
      @location = Geokit::LatLng.new(loc["latitude"], loc["longitude"])
      @data["fuelType"] = "P" # Multicity cars are either electric or super.
    end

    def is_electro?
      @vehicle["powerType"] == "electric"
    end

    def name
      "%s (%s)" % [@vehicle["license"], @vehicle["name"][0..15].strip]
    end

    def needs_fuelling?
      @vehicle["fillLevel"] < 50
    end

    def is_charging?
      false
    end

    def image_url
      "https://www.multicity-carsharing.de/wp-content/plugins/" +
        "multicity_map_v2/img/image_" + (is_electro? ? "multicity" : "c1") +
        ".jpg"
    end

    def marker_icon
      "/images/marker_mc_" + (is_electro? ? "electro" : "therm") + ".svg"
    end

    def reserve_url
      "multicity://bookvehicle?rentalobjectid=" + @vehicle["rentalObjectID"]
    end

    def fuel_in_percent
      @vehicle["fillLevel"]
    end

    def license_plate
      @vehicle["license"]
    end
  end

  class PetrolFS < PetrolFS
    def initialize(hsh)
      loc = hsh["location"]
      hsh["latitude"]     = loc["coordinates"][1]
      hsh["longitude"]    = loc["coordinates"][0]

      hsh["name"]         = hsh["value"]["name"]
      hsh["address"]      = ["-"]
      hsh["organisation"] = ""
      super(hsh)
    end

    def marker_icon
      "/images/station/mc/petrol/img.svg"
    end
  end

  class ElectroFS < ElectroFS
    def initialize(hsh)
      hsh["latitude"]  = hsh["lat"]
      hsh["longitude"] = hsh["lng"]

      @mrkinfo    = hsh["hal2option"]["markerInfo"]
      hsh["name"] = @mrkinfo["name"]

      addr = @mrkinfo["address"]
      hsh["address"] = [ addr["streetName"] + addr["houseNumber"],
                         addr["postalCode"] + " " + addr["city"]]
      hsh["organisation"] = "RWE"
      super(hsh)
    end

    def marker_icon
      "/images/station/mcy/electro/"+(is_crowded? ? "crowded" : "empty")+".svg"
    end

    def capacity_info
      { :free => @mrkinfo["free"].to_i, :total => @mrkinfo["capacity"].to_i }
    end
  end

  class City < City
    module ExtendWithMulticity
      def multicity_broken_json(*args)
        JSON(get(*args).body.
             force_encoding("ISO-8859-1").
             sub(/^[[:space:]+]\},[[:space:]+]\],/,"}],"))
      end
    end

    def self.mechanize_agent
      ::City.mechanize_agent.send(:extend, ExtendWithMulticity)
    end

    def self.all
      [Multicity::City.new("name" => "Berlin, Deutschland", "id" => "403037",
                           "lat" => 52.5166667, "lng" => 13.4)]
    end

    def initialize(hsh)
      super(hsh)
      @location = Geokit::LatLng.new(hsh["lat"], hsh["lng"])
    end

    def name
      data["name"]
    end

    def id
      data["id"]
    end

    def obtain_car_details
      {}.tap do |resp|
        resp[:cars] = self.class.mechanize_agent.
          json("https://www.multicity-carsharing.de"+
               "/_denker-mc.php").map do |hsh|
          Multicity::Car.new(hsh)
        end

        data = {
          "url" => ("/gasstations?lat=#{@location.lat}&lon="+
                    "#{@location.lng}&dist=50000")
        }
        resp[:petrol_stations] = self.class.mechanize_agent.
          jpost("https://www.multicity-carsharing.de/"+
                "_denker-mob.php",data).map do |hsh|
          Multicity::PetrolFS.new(hsh)
        end

        resp[:electro_stations] = self.class.mechanize_agent.
          multicity_broken_json("https://www.multicity-carsharing.de/rwe_utf8/"+
               "json.php?max=10000")["marker"].map do |hsh|
          Multicity::ElectroFS.new(hsh)
        end.reject { |a| a.is_full? }
      end
    end
  end
end

CscProviders.register("mcy", "Multicity", Multicity::City)
