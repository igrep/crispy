require 'crispy'

module RSpec
  module Crispy
    module CrispyHooks

      # required methods by RSpec's mock framework adapter API.

      def setup_mocks_for_rspec
      end

      def verify_mocks_for_rspec
      end

      def teardown_mocks_for_rspec
        ::Crispy::CrispyWorld.reset
      end

    end
  end
end
