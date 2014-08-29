module Crispy
  module CrispyInternal
    module ConstChanger
      @registry = {}
      class << self

        def change_by_name full_const_name, value
        end

        def register full_const_name, value
          @registry[full_const_name] = value
        end

        def recover_all
        end

      end
    end
  end
end

