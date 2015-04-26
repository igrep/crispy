class YourCoolClass
  YOUR_COOL_CONST = 'value before stubbed'.freeze
  def your_cool_method *args
    'cool!'
  end
  def your_method_without_argument
  end
  def your_lovely_method *args
    'lovely!'
  end
  def your_finalizer *args
  end
  def method_to_ignore1
  end
  def method_to_ignore2
  end

  class Again < self
    def your_another_method *args
    end
    def some_method_for_testing
    end
  end
end
