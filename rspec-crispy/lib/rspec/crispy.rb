require 'rspec/crispy/crispy_hooks'
require 'rspec/crispy/crispy_features'
require 'rspec/crispy/version'

module RSpec
  module Crispy
    include ::RSpec::Crispy::CrispyHooks
    include ::RSpec::Crispy::CrispyFeatures

    def self.framework_name
      :crispy
    end

    def self.configure_without_conflict config
      config.after(:each){ ::Crispy::CrispyWorld.reset }
    end

  end
end
