module DriveNow
  extend self

  class City < City
    def self.all
      Curlobj.
        data_for("https://api2.drive-now.com/"+
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
        data_for("https://api2.drive-now.com/cities/#{id}?expand=full")

      {}.tap do |resp|
        resp[:electro_stations] = data["chargingStations"]["items"].map do |hsh|
          ElectroFS.new(hsh)
        end

        resp[:petrol_stations] = data["petrolStations"]["items"].map do |hsh|
          PetrolFS.new(hsh)
        end

        resp[:cars] = data["cars"]["items"].map { |hsh| Car.new(hsh) }
      end
    end
  end
end
