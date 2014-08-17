require "crispy/version"
require "crispy/spy"
require "crispy/double"

module Crispy
  # All methods of this module should be module_function.
  module_function

  # Returns a Spy object to wrap all methods of the object.
  def spy_into object, stubs_map = {}
    ::Crispy::Spy.new object, stubs_map
  end

  def double name_or_stubs_map = nil, stubs_map = {}
    ::Crispy::Double.new name_or_stubs_map, stubs_map
  end

  # Make and returns a Crispy::ClassSpy's instance to spy all instances of a class.
  def spy_on_any_instance_of klass
    raise NotImplementedError, "Sorry, this feature is under construction :("
    ::Crispy::ClassSpy.new klass
  end

  def spy object
    object.__CRISPY_SPY__
  end

  # Begins to log all instances and its received messages of a class.
  # _NOTE_: replace the constant containing the class
  def spy_into_class! klass
    raise NotImplementedError, "Sorry, this feature is under construction :("
    spy_class = spy_on_any_instance_of klass
    stub_const! klass.name, spy_class
    spy_class
  end

  def stub_const! const_name, value
    raise NotImplementedError, "Sorry, this feature is under construction :("
  end

end
