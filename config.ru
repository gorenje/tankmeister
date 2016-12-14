# -*- ruby -*-
require './application.rb'
use Rack::Session::Cookie, :secret => ENV['COOKIE_SECRET']
run Sinatra::Application
