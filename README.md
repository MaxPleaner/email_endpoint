### Brightwheel coding challenge

#### About

This is a Sinatra application.

#### Dependencies

I am not sure what the minimum Ruby version is that can run this code, but
the best bet is to use version 2.3 or newer.

This program also sends shell commands which assume that it's a Unix system
and has the `curl` program installed.

#### Usage

```sh
git clone http://github.com/maxpleaner/brightwheel_challenge
cd brightwheel_challenge
bundle install
bundle exec rackup
```

The `rackup` uses port 9292 by default, but the `-p <port>` option can be
appended to change this.
