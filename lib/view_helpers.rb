module ViewHelpers
  def title
    str = case params[:csc]
          when "dnw" then "DriveNow"
          when "ctg" then "Car2Go"
          else "DriveNow"
          end
    "#{str} Cars"
  end
end
