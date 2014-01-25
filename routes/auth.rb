##
# Grandmaster | StarCraft 2 Ladder (Authentication Routes)
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
        # registration
        get "/register/?" do
            @error = nil
            slim :register
        end
        post "/register/?" do
            begin
                # FIXME: validation of these parameters is absolutely awful
                if !params[:address].include?("@") or !params[:address].include?(".")
                    raise "Invalid E-Mail Address"
                end
                if !params[:tag].include?("#")
                    raise "Invalid Battle Tag"
                end
                player = Player.create(:tag => params[:tag])
                account = Account.create(:name => params[:username],
                                         :password => BCrypt::Password.create(params[:password]),
                                         :address => params[:address],
                                         :player => player.id)
                redirect "/ladder"
            rescue Exception => e
                @error = "Registration failed: #{e.message}"
                slim :register
            end
        end

        # authentication
        get "/logout/?" do
            response.set_cookie("username", { :value => nil })
            @error = "You are now logged out"
            slim :login
        end
        get "/login/?" do
            slim :login
        end
        post "/login/?" do
            begin
                account = Account.first(:name => params[:username])
                if account and BCrypt::Password.new(account.password) == params[:password]
                    response.set_cookie("username", { :value => account.name })
                else
                    raise "Invalid username or password"
                end
                # FIXME: should also do something like setting a unique token here
                # FIXME: as it's currently implemented, changing your cookie's contents will re-authenticate you
                redirect "/ladder"
            rescue Exception => e
                @error = "Authentication failed: #{e.message}"
                slim :login
            end
        end
    end
end
