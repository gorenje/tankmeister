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
      "/images/marker_icon_car.png"
    end

    def reserve_url
      # this will open the drive now app but not much else.
      "drivenow://car?id=#{@data["id"]}"
    end

    def fuel_in_percent
      @data["fuelLevelInPercent"]
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
      "/images/marker_icon_loading" + (is_crowded? ? "_crowded" : "") + ".png"
    end
  end

  class City < City
    def self.all
      Curlobj.
        drivenow_data_for("https://api2.drive-now.com/"+
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

    def car_details
      data = Curlobj.
        drivenow_data_for("https://api2.drive-now.com/cities/#{id}?expand=full")

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
