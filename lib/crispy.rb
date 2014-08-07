require "crispy/version"
require "crispy/spy_wrapper"
require "crispy/double"

module Crispy
end

class << Crispy

  # Returns a SpyWrapper object to wrap all methods of the object.
  def spy_into object, stubs_map = {}
    self::SpyWrapper.new object, stubs_map
  end

  def double name_or_stubs_map = nil, stubs_map = {}
    self::Double.new name_or_stubs_map, stubs_map
  end

  # Make and returns a Crispy::ClassSpy's instance to spy all instances of a class.
  def spy_on_any_instance_of klass
    raise NotImplementedError, "Sorry, this feature is under construction :("
    self::ClassSpy.new klass
  end

  def spy object
    object.instance_eval { @__CRISPY_SPY__ }
  end

  # Begins to log all instances and its spied messages of a class.
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
