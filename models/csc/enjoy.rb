# -*- coding: utf-8 -*-
require 'mechanize'

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
      "https://enjoy.eni.com/img/map/marker_" +
        (is_scooter? ? "scooter":"car") + ".png?0.9.2"
    end

    def image_url
      "https://enjoy.eni.com/img/map/modal/prenotazione" +
        (is_scooter? ? "scooter" : "auto") + ".png"
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
      "https://enjoy.eni.com/img/map/marker_eni_station.png?0.9.2"
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

    def car_details
      {}.tap do |resp|
        agent = Mechanize.new
        agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) '+
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.117 '+
          'Safari/537.36'

        agent.get("https://enjoy.eni.com/en/#{id}/map/")

        resp[:cars] = JSON(agent.post("https://enjoy.eni.com/ajax/"+
                                      "retrieve_vehicles" , {}).body).
          map do |hsh|
          Enjoy::Car.new(hsh)
        end

        resp[:petrol_stations] =
          JSON(agent.post('https://enjoy.eni.com/ajax/retrieve_pois' ,
                          {}).body).select { |hsh| hsh["poiTypeId"] == 2 }.
          map do |hsh|
          Enjoy::PetrolFS.new(hsh)
        end
        resp[:electro_stations] = []
      end
    end
  end
end

CscProviders.register("ejy", "Enjoy", Enjoy::City)
