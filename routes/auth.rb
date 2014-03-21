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
                # validate input
                # FIXME: validation should really be done in the model and not here
                if (params[:username] =~ /[^[:ascii:]]/) != nil or (params[:username] =~ /[^[:alnum:]]/) != nil
                    raise "Username contains invalid characters"
                elsif Account.find(:name => params[:username]) != nil
                    raise "Username already taken"
                elsif Player.find(:tag => params[:tag]) != nil
                    raise "Battle Tag already registered to an account"
                elsif (params[:password] =~ /[^[:ascii:]]/) != nil or (params[:password] =~ /[^[:print:]]/) != nil
                    raise "Password contains invalid characters"
                elsif params[:password] != params[:password2]
                    raise "Passwords do not match"
                elsif (params[:address] =~ /[^[:ascii:]]/) != nil or (params[:address] =~ /[^[:alnum:]@_.+-]/) != nil
                    raise "E-Mail address contains invalid characters"
                elsif not params[:address].include?("@") or not params[:address].include?(".")
                    raise "E-Mail address not valid"
                end

                # add player account and entry
                Database.transaction do
                    account = Account.create(:name => params[:username],
                                            :password => BCrypt::Password.create(params[:password]),
                                            :address => params[:address])
                    player = Player.create(:account => account.id, :tag => params[:tag], :wins => 0, :losses => 0)
                end

                redirect "/ladder"
            rescue Exception => e
                @error = "Registration failed: #{e.message}"
                slim :register
            end
        end

        # authentication
        get "/logout/?" do
            reset_token!(request.cookies["username"])
            response.set_cookie("username", { :value => nil, :max_age => "0" })
            response.set_cookie("token", { :value => nil, :max_age => "0" })
            @error = "You are now logged out"
            slim :login
        end
        get "/login/?" do
            @error = nil
            if authenticated?
                @error = "You are already logged in"
            end
            slim :login
        end
        post "/login/?" do
            begin
                account = Account.first(:name => params[:username])
                if account and BCrypt::Password.new(account.password) == params[:password]
                    reset_token!(account.name)
                    response.set_cookie("username", { :value => account.name })
                    response.set_cookie("token", { :value => Tokens[account.name][:token] }
                else
                    raise "Invalid username or password"
                end
                redirect "/ladder"
            rescue Exception => e
                @error = "Authentication failed: #{e.message}"
                slim :login
            end
        end
    end
end
