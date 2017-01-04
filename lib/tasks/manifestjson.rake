namespace :manifestjson do
  desc "Verify the manifest.json"
  task :verify do
    require 'json'

    cfg = JSON(File.read("public/manifest.webapp"))
    puts "Seems ok"
  end
end
