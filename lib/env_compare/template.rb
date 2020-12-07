# frozen_string_literal: true

# https://stackoverflow.com/a/10241263/2892779
module EnvCompare
  class Template
    def initialize(data:, headers:, theme_base_path:)
      @data = data
      @headers = headers
      @theme_base_path = theme_base_path
    end

    def render(path)
      content = File.read(File.join(@theme_base_path, path))
      t = ERB.new(content)
      t.result(binding)
    end
  end
end
