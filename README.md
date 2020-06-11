# EnvCompare

Compare Heroku ENV variables across environments in an HTML
table.

In a perfect world, you're using a platform or tool for managing your
environment variables across Heroku environments. However, you may
find the need to compare review app settings, staging, or even
production environment variables

This gem helps pull down the environment variables and give you
a little interface to view & compare them with (via a UI)

No server; it's all done via a CLI. It's really just a wrapper around
some commands around the [heroku cli](https://devcenter.heroku.com/articles/heroku-cli) that does some formatting and
munging of the output so you don't have to copy it all to Excel

This gem wraps the heroku CLI tool to generates a small temporary
HTML file & opens it using [launchy](https://github.com/copiousfreetime/launchy)

It automates a few things:
- Hides environment variables that match across all environments
- Puts them in alpha order

It's primarily intended to compare pre-production ENV variables

## Installation

    # Install heroku CLI
    brew tap heroku/brew && brew install heroku

    git clone https://github.com/jaydorsey/env_compare.git && cd env_compare
    bundle
    rake build
    gem install pkg/env_compare-0.1.0.gem

After installation you should have access to the `ec` executable wrapper

> Note: There's no published gem yet. I'm not really sure how useful this is
> but you can install via above or use the development commands below if you
> don't want to build & install the gem locally

## Usage

First, you need to login with heroku cli:

    heroku login

Then, you can use the `ec` command

Create a file showing differences between 2 or more heroku environments:

    ec diff env1 env2 env3

## Development

To test this on your machine locally, after cloning the repo:

    git clone https://github.com/jaydorsey/env_compare.git && cd env_compare
    bundle
    bundle exec exe/ec diff env1 env2

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaydorsey/env_compare.
