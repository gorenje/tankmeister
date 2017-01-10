module CscProviders
  extend self

  def register(csc, name, city_klz)
    (@store ||= {})[csc.to_s] = [name, city_klz]
  end

  def lookup(csc)
    csclu = csc.to_s.split(/_/).first

    @store[csclu] || {
      "all" => ["All Cars", all_cities],
      "any" => ["Closest", all_cities]
    }[csclu] || []
  end

  def name(csc)
    lookup(csc).first
  end

  def cities(csc)
    [lookup(csc).last].flatten
  end

  private

  def all_cities
    @store.values.map(&:last)
  end
end
