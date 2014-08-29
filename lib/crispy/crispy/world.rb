module Crispy
  module Crispy
    module World
      class << self

        def reset
          ::Crispy::CrispyInternal::ConstChanger.recover_all
        end

      end
    end
  end
end
