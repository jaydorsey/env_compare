# frozen_string_literal: true

require 'env_compare/errors'
require 'env_compare/name_space'
require 'env_compare/version'
require 'erb'
require 'launchy'
require 'securerandom'
require 'thor'
require 'pry'

module EnvCompare
  class CLI < Thor
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
    option :matches, type: :boolean, default: false, desc: 'Display matched ENV variables'
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

    private

    def all_keys
      @all_keys ||= Set.new
    end

    def calculated_output(envs)
      all_keys.sort.map do |key|
        results = envs.map { |env| heroku_results[env][key] }
        next if options[:matches] && results.uniq.size >= 2
        next if results.uniq.size == 1 && !options[:all]

        [key, *results]
      end.compact
    end

    def heroku_results(envs = nil)
      @heroku_results ||=
        envs.each_with_object({}) do |env, obj|
          obj[env] = {}
          lines = `heroku config -a #{env}`.split("\n").drop(1)

          lines.each do |line|
            key, _, value = line.partition(':')
            obj[env][key.strip] = value.strip

            all_keys << key.strip
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

    def theme(file)
      return ERB.new(File.read(theme_path(file))) if File.exist?(theme_path(file))

      raise MissingThemeError
    end

    def theme_path(file)
      @theme_path ||= File.join(File.dirname(__dir__), 'themes', "#{file}.erb")
    end
  end
end
