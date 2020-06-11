# EnvCompare

A gem for viewing and comparing environment variables in Heroku.

In a perfect world, you're using a platform or tool for managing your
environment variables across Heroku environments. However, you may
find the need to compare review app settings, staging, or even
production environment variables

This gem helps pull down the environment variables and give you
a little interface to view & compare them with (via a UI)

No server; it's all done via a CLI. It's really just a wrapper around
some commands around the [heroku cli] that does some formatting and
munging of the output so you don't have to copy it all to Excel

## Installation

    brew tap heroku/brew && brew install heroku
    rake build
    gem install pkg/env_compare*

## Usage

First, you need to login with heroku cli:

    heroku login

Create a file showing differences between 2 or more heroku environments:

    env_compare diff env1 env2 env3

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaydorsey/env_compare.
