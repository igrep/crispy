require 'crispy/crispy_internal/const_changer'

module Crispy
  module CrispyWorld
    class << self

      def reset
        ::Crispy::CrispyInternal::ConstChanger.recover_all
        ::Crispy::CrispyInternal::ClassSpy.erase_all_logs
      end

    end
  end
end
