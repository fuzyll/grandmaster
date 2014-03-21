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

require "./settings"
require "./model"

module Grandmaster
    # create ephemeral authentication tokens for every user
    Tokens = {}
    Account.each do |account|
        Tokens[account.name] = { :timestamp => Time.now.to_i, :token => SecureRandom.hex }
    end

    class Application < Sinatra::Base
        # configure application
        configure :production do
            set :slim, :ugly => true
        end
        configure :development do
            set :slim, :pretty => true
        end
        use Rack::Session::Cookie, { :http_only => true, :secret => SecureRandom.hex }
        Settings.each_pair do |key, value|
            set key, value
        end

        # declare helper functions
        helpers do
            # check if a user is authenticated
            def authenticated?
                if not Tokens.has_key?(request.cookies["username"])
                    return false
                elsif Tokens[request.cookies["username"]][:timestamp] < Time.now.to_i - 3600
                    return false
                end
                return request.cookies["token"] == Tokens[request.cookies["username"]][:token]
            end

            # reset a user's authentication token
            def reset_token!(username)
                Tokens[username] = { :timestamp => Time.now.to_i, :token => SecureRandom.hex }
            end
        end

        # declare default routes
        not_found do
            halt 404
        end
        get "/?" do
            redirect "/ladder"
        end

        # require additional routes
        Dir["./routes/*.rb"].each do |route|
            require route
        end
    end
end
