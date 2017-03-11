# -*- coding: utf-8 -*-

module Enjoy
  class Car < Car
    def initialize(hsh)
      hsh["fuelType"] = 'P'
      super(hsh)
      @location = Geokit::LatLng.new(hsh["lat"], hsh["lon"])
    end

    def is_electro?
      false
    end

    def is_scooter?
      @data["car_category_type_id"] == 2
    end

    def name
      @data["car_plate"]
    end

    def needs_fuelling?
      @data["fuel_level"] <= 30
    end

    def is_charging?
      false
    end

    def reserve_url
      "enjoy://reserve?#{@data['virtual_rental_id']}"
    end

    def address_line
      @data["address"]
    end

    def marker_icon
      "/images/car/ejy/" + (is_scooter? ? "scooter":"car") + ".svg"
    end

    def image_url
      "/images/enjoy/prenotazione_" +(is_scooter? ? "scooter" : "auto") + ".png"
    end

    def fuel_in_percent
      @data["fuel_level"]
    end

    def license_plate
      @data["car_plate"]
    end
  end

  class PetrolFS < PetrolFS
    def initialize(hsh)
      hsh["latitude"]     = hsh["lat"]
      hsh["longitude"]    = hsh["lon"]

      hsh["name"]         = hsh["name"]
      hsh["address"]      = [hsh["addres"]]
      hsh["organisation"] = ""
      super(hsh)
    end

    def marker_icon
      "/images/station/ejy/petrol/marker.svg"
    end
  end

  class City < City
    def self.all
      [Enjoy::City.new("name" => "Florence, Italy",
                       "id" => "firenze",
                       "lat" => 43.769562, "lng" => 11.255814),
       Enjoy::City.new("name" => "Milan, Italy",
                       "id" => "milano",
                       "lat" => 45.464211, "lng" => 9.191383),
       Enjoy::City.new("name" => "Rome, Italy",
                       "id" => "roma",
                       "lat" => 41.890251, "lng" => 12.492373),
       Enjoy::City.new("name" => "Turin, Italy",
                       "id" => "torino",
                       "lat" => 45.116177, "lng" => 7.742615),
       Enjoy::City.new("name" => "Catania, Italy",
                       "id" => "catania",
                       "lat" => 37.5079, "lng" => 15.0830)]
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
        agent = City.mechanize_agent

        agent.get("https://enjoy.eni.com/en/#{id}/map/")

        resp[:cars] = agent.
          jpost("https://enjoy.eni.com/ajax/retrieve_vehicles", {}).
          map do |hsh|
          Enjoy::Car.new(hsh)
        end

        resp[:petrol_stations] =
          agent.jpost('https://enjoy.eni.com/ajax/retrieve_pois',{}).
          select { |hsh| hsh["poiTypeId"] == 2 }.
          map do |hsh|
          Enjoy::PetrolFS.new(hsh)
        end

        resp[:electro_stations] = []
      end
    end
  end
end

CscProviders.register("ejy", "Enjoy", Enjoy::City)
