module DriveNow
  class Car < Car
    def initialize(hsh)
      super(hsh)
      @location = Geokit::LatLng.new(@data["latitude"], @data["longitude"])
    end

    def is_electro?
      @data["fuelType"] == "E"
    end

    def name
      "%s (%s)" % [@data["licensePlate"], @data["name"]]
    end

    def needs_fuelling?
      @data["fuelLevel"] <= 0.25
    end

    def is_charging?
      @data["isCharging"]
    end

    def address_line
      @data["address"].join(", ")
    end

    def image_url
      @data["carImageUrl"].gsub(/\{density\}/, "hdpi")
    end

    def marker_icon
      "/images/car/drivenow/" + (is_electro? ? "electro" : "petrol") + ".svg"
    end

    def reserve_url
      # this will open the drive now app but not much else.
      "drivenow://car?id=#{@data["id"]}"
    end

    def fuel_in_percent
      @data["fuelLevelInPercent"]
    end

    def license_plate
      @data["licensePlate"]
    end

    def cleanliness
      case @data["innerCleanliness"]
      when "VERY_CLEAN" then "4/4"
      when "CLEAN"      then "4/3"
      when "REGULAR"    then "4/2"
      else
        "4/1"
      end
    end
  end

  class ElectroFS < ElectroFS
    AssumedCapacity = 2

    def initialize(hsh)
      super(hsh)
      @free = AssumedCapacity
    end

    def increment_car_count
      @free -= 1
    end

    def capacity_info
      { :free => @free, :total => AssumedCapacity }
    end

    def marker_icon
      "/images/marker_icon_loading" + (is_crowded? ? "_crowded" : "") + ".svg"
    end
  end

  class City < City
    module ExtendWithDN
      def json_dn(url)
        json(url, [], nil, {'X-Api-Key' => ENV['DRIVE_NOW_API_KEY']})
      end
    end

    def self.mechanize_agent(user_agent)
      ::City.mechanize_agent(user_agent).send(:extend, ExtendWithDN)
    end

    def self.all
      mechanize_agent("Android App Version 3.18.0").
        json_dn("https://api2.drive-now.com/"+
                "cities?expand=cities")["items"].map do |hsh|
        DriveNow::City.new(hsh)
      end
    end

    def initialize(hsh)
      super(hsh)
      @location = Geokit::LatLng.new(hsh["latitude"], hsh["longitude"])
    end

    def name
      "%s, %s" % [data["name"], data["countryLabel"]]
    end

    def id
      data["id"]
    end

    def obtain_car_details
      data = self.class.mechanize_agent("Android App Version 3.18.0").
        json_dn("https://api2.drive-now.com/cities/#{id}?expand=full")

      {}.tap do |resp|
        resp[:electro_stations] = data["chargingStations"]["items"].map do |hsh|
          DriveNow::ElectroFS.new(hsh)
        end

        resp[:petrol_stations] = data["petrolStations"]["items"].map do |hsh|
          PetrolFS.new(hsh)
        end

        resp[:cars] = data["cars"]["items"].map do |hsh|
          DriveNow::Car.new(hsh)
        end

        resp[:cars].
          select { |car| car.is_charging? }.
          each do |car|
          resp[:electro_stations].nearest( car.location ).first.
            increment_car_count
        end
        resp[:electro_stations].reject! { |fs| fs.is_full? }
      end
    end
  end
end

CscProviders.register("dnw", "DriveNow", DriveNow::City)
