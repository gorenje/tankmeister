# config/unicorn.rb

worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout Integer(ENV['WEB_TIMEOUT'] || 15)
preload_app true

# As recommended by HEROKU for running on HEROKU:
# https://devcenter.heroku.com/articles/rails-unicorn
before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  begin
    $redis_pool.with_each do |con|
      con.client.disconnect
    end
  rescue Redis::CannotConnectError
    $stderr.puts "Cannot quit redis connection"
  end if $redis_pool
end

# As recommended by HEROKU for running on HEROKU:
# https://devcenter.heroku.com/articles/rails-unicorn
after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  begin
    $redis_pool.with_each do |con|
      con.client.reconnect
    end
  rescue Redis::CannotConnectError
    $stderr.puts "Cannot connect to redis"
  end if $redis_pool
end
