# frozen_string_literal: true

require 'erb'
require 'launchy'
require 'securerandom'
require 'platform-api'
require 'pry'
require 'thor'

module EnvCompare
  class Cli < Thor
    attr_accessor :envs

    desc 'version', 'list version'
    def version
      puts EnvCompare::VERSION
    end

    desc 'list ENVIRONMENT', 'List environment variables for a single environment'

    def list(environment)
      output = `heroku config -a #{environment}`
      puts output
    end

    option :theme, type: :string, default: 'dark', desc: 'Theme to use'
    option :all, type: :boolean, default: false, desc: 'Display all ENV variables, including matches'
    desc 'diff heroku-app-name-1 heroku-app-name-2', 'Compare environment variables for 2+ environments'
    def diff(*envs)
      return list(envs.first) if envs.size == 1

      heroku_results(envs)

      html =
        ::EnvCompare::Template.new(
          data: calculated_output(envs),
          headers: ['KEY', envs].flatten,
          theme_base_path: theme_base_path
        ).render(theme_name(options[:theme]))

      save_and_open_file(html)
    end

    option :key, type: :string, desc: 'Key name'
    option :value, type: :string, default: nil, desc: 'Value of key'
    option :force, type: :boolean, default: true, desc: 'Add the ENV, even if it does not exist'
    desc 'update heroku-app-name-1 heroku-app-name-2 --key=MY_KEY --value=test', 'Update environment variable for 1+ environments'
    def update(*apps)
      apps.each do |app|
        if options.force
          config_var_update(app, { options[:key] => options[:value] })
        else
          conditional_config_var_update(app, { options[:key] => options[:value] })
        end
      end
    end

    private

    def all_keys
      @all_keys ||= Set.new
    end

    def calculated_output(envs)
      all_keys.sort.map do |key|
        results = envs.map { |env| heroku_results[env][key] }
        next if results.uniq.size == 1 && !options[:all]

        [key, *results]
      end.compact
    end

    def heroku_results(app_names = nil)
      @heroku_results ||=
        app_names.each_with_object({}) do |app_name, obj|
          obj[app_name] = {}

          env_vars = config_vars_for_app(app_name)

          env_vars.each do |key, value|
            obj[app_name][key] = value

            all_keys << key
          end
        end
    end

    def save_and_open_file(html)
      filename = "#{SecureRandom.hex(32)}.html"
      output = File.open(filename, 'w')
      output.write(html)
      output.close

      full_path = File.join(Dir.pwd, output.path)

      Launchy.open(full_path)

      sleep(1)

      File.delete(full_path)
    end

    def config_vars_for_app(app_name)
      heroku.config_var.info_for_app(app_name)
    end

    def heroku
      @heroku ||= PlatformAPI.connect_oauth(ENV.fetch('OAUTH_TOKEN'))
    end

    # Returns a filename.ext when given a filename
    #
    # Also checks to make sure the file exists.
    def theme_name(theme)
      theme_file = "#{theme}.html.erb"

      path = File.join(theme_base_path, theme_file)

      return theme_file if File.exist?(path)

      raise MissingThemeError
    end

    # Returns a path representing where themes are stored in the library
    #
    # Used for the ERB templates to resolve file locations
    def theme_base_path
      @theme_base_path ||= File.expand_path(File.join(File.dirname(__dir__), '..', 'themes'))
    end

    def config_var_update(app_name, env_hash)
      heroku.config_var.update(app_name, env_hash)
    end

    def conditional_config_var_update(app_name, env_hash)
      return if config_vars_for_app(app_name)[options[:key]].nil?

      config_var_update(app_name, env_hash)
    end
  end
end
