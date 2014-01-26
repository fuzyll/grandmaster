##
# Grandmaster | StarCraft 2 Ladder (Content Routes)
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
        # ladder
        get "/ladder/?" do
            @players = Player.order(:rating).all
            slim :ladder
        end

        # game list
        get "/games/?" do
            @games = Game.reverse_order(:timestamp).all
            slim :games
        end

        # uploads
        get "/upload/?" do
            slim :upload
        end
        post "/upload/?" do
            begin
                # save the uploaded file to disk
                data = params[:file][:tempfile].read
                filename = "#{settings.upload_folder}/#{Digest::SHA1.hexdigest(data)}.SC2Replay"
                if File.exists?(filename)
                    @error = "Upload failed: Replay already uploaded"
                    return slim :upload
                end
                File.open(filename, "w") do |file|
                    file.write(data)
                end

                # parse the replay and validate it
                # FIXME: should maybe do the validation in the model? (might be very difficult, though)
                replay = Tassadar::SC2::Replay.new(filename)
                if replay.game.speed != "Faster"
                    raise "Games must be played on Faster speed to be accepted"
                end
                if replay.players.length != 2 or replay.game.type != "1v1"
                    raise "Only 1v1 games are supported at this time"
                end
                replay.players.each do |player|
                    if not Player.find(:tag => player.name)
                        raise "All players must be on the ladder for replays to be accepted"
                    end
                end
                if not Map.find(:name => replay.game.map) or not Map.find(:name => replay.game.map).current
                    raise "Map is not in the current ladder map pool"
                end

                # determine match quality and update ratings
                # FIXME: this could probably be accomplished with less variables and more comments
                # FIXME: everything below also assumes a 1v1 match, which shouldn't necessarily be the case
                replay_winner = (replay.players.select { |player| player.won == true })[0]
                replay_loser = (replay.players.select { |player| player.won == false })[0]
                winner = Player.find(:tag => replay_winner.name)
                loser = Player.find(:tag => replay_loser.name)
                winner_old_rating = TrueSkillEnv.Rating(winner.rating, winner.confidence)
                loser_old_rating = TrueSkillEnv.Rating(loser.rating, loser.confidence)
                match_quality = TrueSkillEnv.match_quality([[winner_old_rating], [loser_old_rating]])
                new_ratings = TrueSkillEnv.transform_ratings([[winner_old_rating], [loser_old_rating]], [0, 1])
                winner_new_rating = new_ratings[0][0]
                loser_new_rating = new_ratings[1][0]

                # place the game in the database
                # FIXME: debug below
                puts "Filename: #{filename.split("/")[-1]}"
                puts "Game Type: #{replay.game.type}"
                puts "Map: #{replay.game.map}"
                puts "Timestamp: #{replay.game.time}"
                puts "Winner: #{winner.tag}"
                puts "Winner Race: #{replay_winner.actual_race}"
                puts "Winner Rating Change: #{winner_new_rating.mu - winner_old_rating.mu}"
                puts "Winner New Confidence: #{winner_new_rating.sigma}"
                puts "Loser: #{loser.tag}"
                puts "Loser Race: #{replay_loser.actual_race}"
                puts "Loser Rating Change: #{loser_new_rating.mu - loser_old_rating.mu}"
                puts "Winner New Confidence: #{winner_new_rating.sigma}"
                puts "Match Quality: #{match_quality}"
                # FIXME: debug above
                Game.create(:replay => filename.split("/")[-1],
                            :type => replay.game.type,
                            :map => Map.find(:name => replay.game.map).id,
                            :timestamp => replay.game.time,
                            :winner => winner.id,
                            :winner_race => Race.find(:name => replay_winner.actual_race).id,
                            :winner_change => winner_new_rating.mu - winner_old_rating.mu,
                            :loser => loser.id,
                            :loser_race => Race.find(:name => replay_loser.actual_race).id,
                            :loser_change => loser_new_rating.mu - loser_old_rating.mu,
                            :quality => match_quality)

                # update player entries in the database
                # FIXME: this should really be done in a transaction along with the above row creation (race condition)
                winner.update(:rating => winner_new_rating.mu)
                winner.update(:confidence => winner_new_rating.sigma)
                loser.update(:rating => loser_new_rating.mu)
                loser.update(:confidence => loser_new_rating.sigma)

                redirect "/ladder"
            rescue Exception => e
                File.delete(filename)  # FIXME: what happens if we couldn't read the file and don't have a filename?
                @error = "Upload failed: #{e.message}"
                slim :upload
            end
        end

    end
end
