require "env_compare/name_space"
require "env_compare/version"
require "erb"
require "launchy"
require "set"
require "securerandom"
require "thor"

module EnvCompare
  class CLI < Thor
    desc "version", "list version"
    def version
      puts EnvCompare::VERSION
    end

    desc "list ENVIRONMENT", "List environment variables for a single environment"

    def list(environment)
      output = `heroku config -a #{environment}`
      puts output
    end

    option :all, type: :boolean, default: false, desc: "Display all ENV variables, including matches"
    desc "diff ENV1 ENV2", "Compare environment variables for 2+ environments"
    def diff(*envs)
      if envs.size == 1
        list(envs.first)
      else
        all_keys = Set.new

        res = envs.each_with_object({}) do |env, obj|
          puts "Fetching #{env} environment variables"
          obj[env] = {}
          lines = `heroku config -a #{env}`.split("\n")
          lines = lines.drop(1)

          lines.each do |line|
            key, _, value = line.partition(":")
            obj[env][key.strip] = value.strip

            all_keys << key.strip
          end
        end

        same_keys = Set.new

        different_results = all_keys.sort.map { |key|
          results = envs.map { |env| res[env][key] }
          next if results.uniq.size == 1 && !options[:all]
          [key, *results]
        }.compact

        template = ERB.new <<~TEMPLATE
          <html>
            <head>
            <style>
            table {
              background: #121212;
              color: #af87ff;
              table-layout: fixed;
              width: 100%;
            }

            table, th, td {
              border: 1px solid #424d66;
              border-collapse: collapse;
            }

            th {
              color: #ff9700;
              font-family: Arial, Helvetica, sans-serif;
              letter-spacing: 1px;
            }

            td {
              padding: 10px;
              word-wrap: break-word;
            }

            td:first-child {
              color: #62d8f1;
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

        # https://stackoverflow.com/a/5462069/2892779
        html =
          template.
            result(
              ::EnvCompare::NameSpace.new(
                data: different_results,
                headers: ["KEY", envs].flatten
              ).get_binding
            )

        filename = "#{SecureRandom.hex(32)}.html"
        output = File.open(filename, "w")
        output.write(html)
        output.close

        full_path = File.join(Dir.pwd, output.path)

        Launchy.open(full_path)

        sleep(1)

        File.delete(full_path)
      end
    end
  end
end
