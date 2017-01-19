class Array
  def nearest(location)
    map do |obj|
      [obj, obj.distance_to(location)]
    end.sort_by do |_,dist|
      dist
    end.map do |obj, _|
      obj
    end
  end
end
