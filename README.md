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

### Prerequisites
- Install Heroku CLI
  ```bash
  brew tap heroku/brew && brew install heroku
  ```

- Login with Heroku CLI
  ```bash
  heroku login
  ```

### Install gem
```bash
gem install env_compare
```

After installation you should have access to the `ec` executable wrapper.


## Usage
Use `ec` command to start comparing 2 or more heroku application environment variables.

When only one application name is specified, output is shown in cli. Otherwise, your default browser is launched.

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
- `--theme dark` **default*
- `--theme light`

For Example:
```bash
ec diff --theme light heroku-app-name1 heroku-app-name2
```

## Development

To test this on your machine locally, after cloning the repo:

    git clone https://github.com/jaydorsey/env_compare.git && cd env_compare
    bundle
    bundle exec ec diff heroku-app-name1 heroku-app-name2

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaydorsey/env_compare.
