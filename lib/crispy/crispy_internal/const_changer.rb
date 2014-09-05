module Crispy
  module CrispyInternal
    module ConstChanger

      @registry = {}

      class << self

        def change_by_full_name full_const_name, value
          const_names = full_const_name.split('::'.freeze)

          const_names.shift if const_names.first.empty?

          target_const_name = const_names.pop

          module_containing_target_const =
            const_names.inject(::Kernel) do|const_value, const_name|
              const_value.const_get const_name
            end

          saved_value = module_containing_target_const.module_eval do
            remove_const target_const_name
          end
          module_containing_target_const.const_set target_const_name, value

          saved_value
        end

        def save full_const_name, value
          @registry[full_const_name] = value
        end

        def recover_all
          @registry.each do|full_const_name, saved_value|
            self.change_by_full_name(full_const_name, saved_value)
          end
        end

      end
    end
  end
end
