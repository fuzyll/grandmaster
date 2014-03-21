# Grandmaster #

Grandmaster is a small little web application for managing a custom StarCraft 2 ladder.

## Features ##

* Parses uploaded replays with Tassadar (so you don't need manual entry of anything)
* Ranks players using Microsoft's TrueSkill algorithm

## Usage ##

The following will install all dependencies and start the Grandmaster on port 9292:

```
# the following assumes Ubuntu 12.04
sudo apt-get install ruby1.9.1 ruby1.9.1-dev sqlite3 libsqlite3-dev
gem install bundler
bundle install --standalone
bundle exec rackup config.ru
```

Grandmaster can be run with a traditional webserver like Apache using Passenger,
but there ain't nobody that has time to write documentation for that (at least, not right now, anyway).

## Configuration ##

Configuration is done in the `settings.yml` file.

## Roadmap ##

The following need to be completed before Grandmaster is usable:

* Haven't tested with a large selection of replays
* Need to prevent attacks on authentication (not currently using tokens)
* Need some way to re-validate all rankings (ratings are updated at time of upload, but games may not necessarily
  be uploaded in that order, which can create opportunities for players to game the system)

The following is a list of features that have yet to be added:

* Support needs to be added for game types other than 1v1
* An administrative interface should be added (to allow for walkovers, map pool rotations, and so on)
* More support for tournaments/leagues should be added
* TrueSkill should potentially be replaced for ranking (it almost ranks too well...better for just matchmaking)
* More personalization should be added (so there's actually a reason to log in)
* A scheduling interface would probably be useful, as would automated e-mail reminders
