##
# Grandmaster | StarCraft 2 Ladder (Model)
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
        # open our database
        # FIXME: should support Postgres as well
        Database = Sequel.sqlite("./grandmaster.db")

        # create tables if they do not already exist
        Database.create_table?("players") do
            primary_key :id
            timestamp :timestamp, {
                :default => Sequel::CURRENT_TIMESTAMP,
                :null => false
            }
            string :name, { :size => 32, :unique => true, :null => false }
            string :password, { :size => 64, :null => false }
            string :address, { :size => 64 }
            string :tag, { :size => 32, :unique => true }
            integer :rating, { :null => false }
        end

        # auto-generate classes representing the model for our database
        class Player < Sequel::Model; end
    end
end
