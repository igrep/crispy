require "crispy/version"
require "crispy/crispy_internal/spy"
require "crispy/crispy_internal/double"
require "crispy/crispy_internal/const_changer"
require "crispy/crispy/world"

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
  def spy_on_any_instance_of klass
    raise NotImplementedError, "Sorry, this feature is under construction :("
    ::Crispy::CrispyInternal::ClassSpy.new klass
  end

  def spy object
    object.__CRISPY_SPY__
  end

  # Begins to log all instances and its received messages of a class.
  # _NOTE_: replace the constant containing the class
  def spy_into_class klass
    raise NotImplementedError, "Sorry, this feature is under construction :("
    spy_class = spy_on_any_instance_of klass
    stub_const! klass.name, spy_class
    spy_class
  end

  def stub_const full_const_name, value
    const_names = full_const_name.split('::'.freeze)

    const_names.shift if const_names.first.empty?

    target_const_name = const_names.pop

    module_containing_target_const = const_names.inject(::Kernel) do|const_value, const_name|
      const_value.const_get const_name
    end
    const_value_save = module_containing_target_const.module_eval do
      remove_const target_const_name
    end
    module_containing_target_const.const_set target_const_name, value
    ::Crispy::CrispyInternal::ConstChanger.register full_const_name, const_value_save
  end

end
