# Grandmaster #

Grandmaster is a small little web application for managing a custom StarCraft 2 ladder.

## Features ##

* Parses uploaded replays with Tassadar (so you don't need manual entry of anything)
* Ranks players using Microsoft's TrueSkill algorithm

## Usage ##

The following will install all dependencies and start the Grandmaster on port 9292:

```
# the following assumes Ubuntu 12.04
sudo apt-get install ruby1.9.1
gem install bundler
bundle install --standalone
bundle exec rackup application.ru
```

Grandmaster can be run with a traditional webserver like Apache using Passenger,
but there ain't nobody that has time to write documentation for that (at least, not right now, anyway).

## Configuration ##

Configuration is done in the `settings.yml` file.

## Roadmap ##

The following need to be completed before Grandmaster is usable:

* Haven't tested with a large selection of replays
* Need to prevent attacks on authentication (not currently using tokens)
* Need to prevent race conditions on database with transactions
* Need to create a theme so that pages aren't just black text on a white background

The following is a list of features that have yet to be added:

* Support needs to be added for game types other than 1v1
* An administrative interface should be added (to allow for walkovers, map pool rotations, and so on)
* More support for tournaments/leagues should be added
* TrueSkill should potentially be replaced for ranking (it almost ranks too well...better for just matchmaking)
* More personalization should be added (so there's actually a reason to log in)
