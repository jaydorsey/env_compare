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

      # https://stackoverflow.com/a/5462069/2892779
      html =
        theme(options[:theme]).
          result(
            ::EnvCompare::NameSpace.new(data: calculated_output(envs), headers: ['KEY', envs].flatten).get_binding
          )

      save_and_open_file(html)
    end

    # ec update app1 app2 KEY_NAME value
    option :key, type: :string, desc: 'Key name'
    option :value, type: :string, default: nil, desc: 'Value of key'
    desc 'update heroku-app-name-1 heroku-app-name-2 MY_KEY test', 'Update environment variable for 1+ environments'
    def update(*apps)
      apps.each do |app|
        update_config(app, { options[:key] =>  options[:value] })
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
      @heroku ||= PlatformAPI.connect_oauth(ENV['OAUTH_TOKEN'])
    end

    def theme(file)
      return ERB.new(File.read(theme_path(file))) if File.exist?(theme_path(file))

      raise MissingThemeError
    end

    def theme_path(file)
      @theme_path ||= File.join(File.dirname(__dir__), '..', 'themes', "#{file}.erb")
    end

    def update_config(app, body)
      heroku.config_var.update(app, body)
    end
  end
end
