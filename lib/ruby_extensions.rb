class Array
  def nearest(location)
    return self if location.nil?
    compact.map do |obj|
      [obj, obj.distance_to(location)]
    end.sort_by do |_,dist|
      dist
    end.map do |obj, _|
      obj
    end
  end
end
