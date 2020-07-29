# EnvCompare

Compare Heroku ENV variables across environments in an HTML
table.

In a perfect world, you're using a platform or tool for managing your
environment variables across Heroku environments. However, you may
find the need to compare review app settings, staging, or even
production environment variables

This gem helps pull down the environment variables and give you
a little interface to view & compare them with (via a UI)

The heavy lifting is done via the [heroku platform-api gem](https://github.com/heroku/platform-api)
to retrieve environment variables, format them in an HTML page, and
generate a small HTML file and open it with [launchy](https://github.com/copiousfreetime/launchy)

It automates a few things:
- Hides environment variables that match across all environments
- Puts them in alpha order

It's primarily intended to compare pre-production ENV variables
across similar/identical environments

## Installation

### Prerequisites

```bash
# Install Heroku CLI
brew tap heroku/brew && brew install heroku

# Login with Heroku CLI
heroku login

# Install the heroku oauth plugin to generate an OAuth token
heroku plugins:install heroku-cli-oauth

# Create a token to access your applications
heroku authorizations:create -d "Platform API token for environment variables"

# Set the Token from above to an environment variable
export OAUTH_TOKEN=<token>
```

If you want to add the environment variable to your shell permanently, you can
run a variation of the command below:

```bash
# Add permanently to `.bash_profile`
echo 'export OAUTH_TOKEN=<token>' >>~/.bash_profile
```

### Install gem
```bash
gem install env_compare
```

After installation you should have access to the `ec` executable wrapper.

## Usage
Use `ec` command to start comparing 2 or more heroku application environment variables.

When only one application name is specified, output is shown in cli. Otherwise, your default browser is launched.

## Compariing environment variables

### Show **differences** **default*
```bash
ec diff heroku-app-name1 heroku-app-name2 heroku-app-name3
```

### Show **all**
add `--all` option:
```bash
ec diff --all heroku-app-name1 heroku-app-name2 heroku-app-name3
```

### Themes
- `--theme dark` **default**
- `--theme light`

For Example:
```bash
ec diff --theme light heroku-app-name1 heroku-app-name2
```

## Updating environment variables across multiple apps

You can use `ec update` to set or clear an environment variable across multiple Heroku
applications.

### Update an environment variable

```bash
ec update heroku-app-name1 heroku-app-name2 heroku-app-name3 --key=MY_KEY --value=asdf
```

### Clear an environment variable

The default key value is nil; omit the `--key` argument if you want to clear an
environment variable.

```bash
ec update heroku-app-name1 heroku-app-name2 heroku-app-name3 --key=MY_KEY
```
## Development

To test this on your machine locally, after cloning the repo:

    git clone https://github.com/jaydorsey/env_compare.git && cd env_compare
    bundle
    bundle exec ec diff heroku-app-name1 heroku-app-name2

You can also optionally build & install the gem locally to test:

    rake build
    gem install pkg/env_compare.<version_number>.gem

Then, use the `ec` command as normal.

### Publishing the gem

If you have access to publish the gem on rubygems:

    rake build
    cd pkg
    gem push env_compare.<version_number>.gem

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaydorsey/env_compare.
