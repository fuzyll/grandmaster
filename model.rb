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
        if settings.database_type == "postgres"
            # FIXME: we don't actually support postgres yet...
            Database = nil
        elsif settings.database_type == "sqlite"
            Database = Sequel.sqlite(settings.database)
        else
            # FIXME: should probably gracefully handle this error case...
            Database = nil
        end

        # create tables if they do not already exist
        Database.create_table?("accounts") do
            primary_key :id
            timestamp :timestamp, { :default => Sequel::CURRENT_TIMESTAMP, :null => false }
            string :name, { :size => 32, :unique => true, :null => false }
            string :password, { :size => 64, :null => false }
            string :address, { :size => 64 }
            integer :player, { :key => :players, :null => false }
        end
        Database.create_table?("players") do
            primary_key :id
            string :tag, { :size => 32, :unique => true }
            integer :race, { :key => :races }
            float :rating, { :default => 3000.0, :null => false }
            float :confidence, { :default => 3000.0/3, :null => false }
        end
        Database.create_table?("races") do
            primary_key :id
            string :name, { :size => 16, :unique => true }
        end
        Database.create_table?("maps") do
            primary_key :id
            string :name, { :size => 32, :unique => true }
            boolean :current, { :default => true }
        end
        Database.create_table?("rules") do
            primary_key :id
            string :name, { :size => 16, :unique => true, :null => false }
        end
        Database.create_table?("games") do
            primary_key :id
            string :replay, { :size => 64, :null => false }
            integer :type, { :key => :rules, :null => false }
            integer :map, { :key => :maps, :null => false }
            timestamp :timestamp, { :default => Sequel::CURRENT_TIMESTAMP, :null => false }
            integer :winner, { :key => :players, :null => false }
            integer :winner_race, { :key => :races, :null => false }
            float :winner_change, { :null => false }
            integer :loser, { :key => :players, :null => false }
            integer :loser_race, { :key => :races, :null => false }
            float :loser_change, { :null => false }
            float :quality, { :null => false }
        end

        # auto-generate classes representing the model for our database
        class Account < Sequel::Model; end
        class Player < Sequel::Model; end
        class Race < Sequel::Model; end
        class Map < Sequel::Model; end
        class Rule < Sequel::Model; end
        class Game < Sequel::Model; end

        # populate races if they don't already exist in the table
        ["Terran", "Zerg", "Protoss"].each do |race|
            Race.find_or_create(:name => race)
        end

        # populate maps if they don't already exist in the table
        Map.each do |entry|
            entry.current = false
        end
        settings.maps.each do |map|
            entry = Map.find_or_create(:name => map)
            entry.current = true
        end

        # populate rules if they don't already exist in the table
        settings.rules.each do |rule|
            Rule.find_or_create(:name => rule)
        end

        # create the trueskill environment
        TrueSkillEnv = TrueSkillObject.new(3000.0, 3000.0/3, 3000.0/6, 3000.0/300, 0)
    end
end
