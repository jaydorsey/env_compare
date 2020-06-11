# frozen_string_literal: true
module EnvCompare
  class NameSpace
    def initialize(hash)
      hash.each do |key, value|
        singleton_class.send(:define_method, key) { value }
      end
    end

    def get_binding
      binding
    end
  end
end
