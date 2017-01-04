get '/.well-known/acme-challenge/:id' do
  env_key = ENV.keys.select { |a| a =~ /ACME_TOKEN/ }.
    select { |a| ENV[a] == params[:id] }.first

  ENV[env_key.sub(/TOKEN/, "KEY")] unless env_key.nil?
end
