require 'timezone'
Timezone::Lookup.config(:google) do |c|
  c.api_key = ENV['GOOGLE_API_KEY']
end
