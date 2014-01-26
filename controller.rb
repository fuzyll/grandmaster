##
# Grandmaster | StarCraft 2 Ladder (Controller)
#
# Copyright (c) 2014 Alexander Taylor <ajtaylor@fuzyll.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
##

module Grandmaster
    class Application < Sinatra::Base
        # configure application
        configure :production do
            set :slim, :ugly => true
        end
        configure :development do
            set :slim, :pretty => true
        end
        use Rack::Session::Cookie, { :http_only => true, :secret => SecureRandom.hex }
        File.open("settings.yml", "r") do |file|
            YAML.load(file.read()).each_pair do |key, value|
                set key, value
            end
        end

        # require application dependencies
        require "./model"
        Dir["./routes/*.rb"].each do |route|
            require route
        end

        # declare default routes
        not_found do
            halt 404
        end
        get "/?" do
            redirect "/ladder"
        end
    end
end
