# -*- ruby -*-
require './application.rb'
use Rack::Session::Cookie, :secret => "asdasdasdasdasdasd"
run Sinatra::Application
