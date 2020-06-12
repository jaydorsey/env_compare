# frozen_string_literal: true

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

    option :all, type: :boolean, default: false, desc: 'Display all ENV variables, including matches'
    desc 'diff ENV1 ENV2', 'Compare environment variables for 2+ environments'
    def diff(*envs)
      return list(envs.first) if envs.size == 1

      heroku_results(envs)

      # https://stackoverflow.com/a/5462069/2892779
      html =
        template.
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

    def template
      @template ||=
        ERB.new <<~TEMPLATE
          <html>
            <head>
            <style>
            body {
              background: #000;
              font-family: Arial, Helvetica, sans-serif;
            }
            table {
              color: #da8fff;
              table-layout: fixed;
              width: 100%;
            }

            table, th, td {
              border: 1px solid #636366;
              border-collapse: collapse;
            }

            th {
              color: #ffb340;
              letter-spacing: 1px;
            }

            td {
              padding: 10px;
              word-wrap: break-word;
            }

            td:first-child {
              color: #409cff;
            }
            </style>
            </head>
            <body>
              <table>
                <tr>
                <% headers.each do |header| %>
                  <th><%= header %></th>
                <% end %>
                </tr>
                <% data.each do |row| %>
                  <tr>
                    <% row.each do |cell| %>
                      <td>
                        <% unless cell.nil? %>
                          <code><%= cell %></code>
                        <% end %>
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              </table>
            </body>
          </html>
        TEMPLATE
    end
  end
end
