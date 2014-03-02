# include necessary dependencies (try local first, then system-wide)
begin
    require "./bundle/bundler/setup"
    require "bundler"
    Bundler.require
rescue LoadError
    require "bundler"
    Bundler.setup
    Bundler.require
end

# set up logging when in production mode
if ENV["RACK_ENV"] == "production"
    log = File.new("logs/sinatra.log", "a")
    STDERR.reopen(log)
end

# include our application's controller and run our application
require "./controller"
run Grandmaster::Application

