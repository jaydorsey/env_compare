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

After installation you should have access to the `ec` executable

## Usage

First, you need to login with heroku cli:

    heroku login

Then, you can use the `ec` command

Create a file showing differences between 2 or more heroku environments:

    ec diff env1 env2 env3

## Development

To test this on your machine locally, after cloning the repo:

    bundle
    bundle exec exe/ec diff env1 env2

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaydorsey/env_compare.
