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
      !!@data["isCharging"]
    end

    def address_line
      @data["address"].join(", ")
    end

    def image_url
      @data["carImageBaseUrl"].
        gsub(/assets\/cars\/\{/, "assets/cars/_fastlane/{").
        gsub(/\{density\}/, "ldpi").
        gsub(/\{model\}/, @data["modelIdentifier"]).
        gsub(/\{color\}/, @data["color"])
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

  class CarJumpCar < DriveNow::Car
    def initialize(hsh)
      rest = {}.tap do |ch|
        ch["fuelLevelInPercent"] = hsh["obj"]["fuelState"]
        ch["fuelLevel"]          = hsh["obj"]["fuelState"] / 100.0
        ch["licensePlate"]       = hsh["obj"]["sign"]
        ch["id"]                 = hsh["obj"]["vin"]
        ch["color"]              = hsh["obj"]["color"]
        ch["modelIdentifier"]    = hsh["obj"]["model"].gsub(/ /, "_")
        ch["latitude"]           = hsh["loc"].last
        ch["longitude"]          = hsh["loc"].first
        ch["carImageBaseUrl"] = "https://prod.drive-now-content.com/"+
          "fileadmin/user_upload_global/assets/cars/_fastlane/"+
          "{model}/{color}/{density}/car.png"
        ch["fuelType"] = case hsh["obj"]["engineType"]
                         when "electric" then "E"
                         when "petrol"   then "P"
                         when "diesel"   then "D"
                         end
      end

      super(hsh["obj"].merge(rest))
    end

    def is_charging?
      false
    end

    def address_line
      false
    end

    def name
      "%s" % @data["licensePlate"]
    end

    def cleanliness
      case @data["innerCleanliness"]
      when "good" then "4/4"
      when "ok"   then "4/3"
      when "bad"  then "4/2"
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
        json(url, [], nil, {'X-Api-Key' => ENV["DRIVE_NOW_API_KEY"]})
      end

      def cj_token
        Base64.encode64(ENV['CARJUMP_SECRET']).strip
      end

      def json_cj(url)
        json(url, [], nil, {'Authorization' => "Basic #{cj_token}"})
      end
    end

    def self.mechanize_agent(user_agent)
      ::City.mechanize_agent(user_agent).send(:extend, ExtendWithDN)
    end

    def self.all
      mechanize_agent("Android-4.2.0").
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
      data = self.class.mechanize_agent("Android-4.2.0").
        json_dn("https://api2.drive-now.com/cities/#{id}?expand="+
                "chargingStations,petrolStations,cities")

      {}.tap do |resp|
        resp[:electro_stations] = data["chargingStations"]["items"].map do |hsh|
          DriveNow::ElectroFS.new(hsh)
        end

        resp[:petrol_stations] = data["petrolStations"]["items"].map do |hsh|
          PetrolFS.new(hsh)
        end

        if !location.valid?
          @location = Geokit::LatLng.new(data["latitude"], data["longitude"])
        end

        maxPt, minPt = [@location.endpoint(315,20000),
                        @location.endpoint(135,20000)]

        resp[:cars] = self.class.mechanize_agent("okhttp/3.7.0").
          json_cj("https://backend.carjump.de/v2/?status=1&"+
                  "minLat=#{minPt.lat}&minLng=#{minPt.lng}&"+
                  "maxLat=#{maxPt.lat}&maxLng=#{maxPt.lng}&"+
                  "provider=driveNow&"+
                  "engineType=diesel,petrol,gas,electric,")["vehicles"].
          select { |hsh| hsh["provider"] == "drivenow" }.
          map do |hsh|
          DriveNow::CarJumpCar.new(hsh)
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
