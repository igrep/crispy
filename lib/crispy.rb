require "crispy/version"
require "crispy/crispy_internal/spy"
require "crispy/crispy_internal/class_spy"
require "crispy/crispy_internal/double"
require "crispy/crispy_world"

module Crispy
  # All methods of this module should be module_function.
  module_function

  # Returns a Spy object to wrap all methods of the object.
  def spy_into object, stubs_map = {}
    ::Crispy::CrispyInternal::Spy.new object, stubs_map
  end

  def double name_or_stubs_map = nil, stubs_map = {}
    ::Crispy::CrispyInternal::Double.new name_or_stubs_map, stubs_map
  end

  # Make and returns a Crispy::ClassSpy's instance to spy all instances of a class.
  def spy_into_instances klass, stubs_map = {}
    ::Crispy::CrispyInternal::ClassSpy.new klass
  end

  def spy object
    object.__CRISPY_SPY__
  end

  def spy_of_instances klass
    klass.__CRISPY_CLASS_SPY__
  end

  def stub_const full_const_name, value
    saved_value = ::Crispy::CrispyInternal::ConstChanger.change_by_full_name full_const_name, value
    ::Crispy::CrispyInternal::ConstChanger.save full_const_name, saved_value
  end

end
