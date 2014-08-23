module Crispy
  module ClassSpy
  end
end

class << Crispy::ClassSpy
  def new klass
    Class.new(klass) do
    end
  end
end
