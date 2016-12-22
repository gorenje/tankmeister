namespace :manifestjson do
  desc "Verify the manifest.json"
  task :verify do
    require 'json'

    cfg = JSON(File.read("public/manifest.json"))
    puts "Seems ok"
  end
end
