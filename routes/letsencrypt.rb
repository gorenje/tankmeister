get "/.well-known/acme-challenge/#{ENV['ACME_TOKEN']}" do
  ENV['ACME_KEY']
end
