require 'timezone'
Timezone::Lookup.config(:google) do |c|
  c.api_key = ENV['GOOGLE_API_KEY']
end

module TzCache
  extend self

  def cache
    @@cache ||= {}
  end

  def lookup(lat, lng)
    loc = Geokit::LatLng.new(lat, lng)
    key = cache.keys.nearest(loc).first

    return cache[key] if key && key.distance_to(loc) < 30000

    begin
      Timezone.lookup(lat,lng).tap do |tz|
        cache[loc] = tz
      end
    rescue Timezone::Error::Google => e
      Timezone['UTC']
    end
  end
end
