require 'crispy/crispy_internal/const_changer'

module Crispy
  module CrispyWorld
    class << self

      def reset
        ::Crispy::CrispyInternal::ConstChanger.recover_all
      end

    end
  end
end
