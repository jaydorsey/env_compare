# frozen_string_literal: true

module EnvCompare
  class MissingThemeError < StandardError
    def message
      <<~MSG


        Theme not found. Use one of:

            --theme light
            --theme dark
      MSG
    end
  end
end
