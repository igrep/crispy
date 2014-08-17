# Crispy

Minimalistic test double library in Ruby - only privides Spy and Stub!

But sorry, there're MANY features **not actually implemented**!

## Features

- Test spy for any object by using `prepend` (Sorry, it runs by Ruby 2.0 or higher!)
- Extremely flexible query for received messages with `received_messages` method.

## Installation

Add this line to your application's Gemfile:

    gem 'crispy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crispy

## Usage

<!--
# Sample class for doctest.
doctest_require: './test/doctest-fixtures/your_cool_class.rb'
-->

### Spy on a Object

```ruby
>> require 'crispy'
>> include Crispy # import spy, spy_into and any other functions from Crispy namespace.

>> object = YourCoolClass.new
>> spy = spy_into object

>> object.your_cool_method 1, 2, 3
>> object.your_method_without_argument
>> object.your_lovely_method 'great', 'arguments'
>> object.your_lovely_method 'great', 'arguments', 'again'
>> object.your_finalizer 'resource to release'

# NOTE: Call query methods through the spy object, instead of YourCoolClass's instance.

# No arguments
>> spy(object).received? :your_cool_method
=> true
>> spy(object).received? :your_method_without_argument
=> true
>> spy(object).received? :your_lovely_method
=> true
>> spy(object).received? :your_ugly_method
=> false

# With arguments (each argument is compared by == method)
>> spy(object).received? :your_cool_method, 1, 2, 3
=> true
>> spy(object).received? :your_cool_method, 0, 0, 0
=> false
>> spy(object).received? :your_method_without_argument, :not, :given, :arguments
=> false
>> spy(object).received? :your_lovely_method, 'great', 'arguments'
=> true
>> spy(object).received? :your_ugly_method, 'of course', 'I gave no arguments'
=> false

# With arguments and block
### Sorry, I'm still thinking of the specification for that case ###

# Count method calls
>> spy(object).count_received :your_cool_method
=> 1
>> spy(object).count_received :your_cool_method, 1, 2, 3
=> 1
>> spy(object).count_received :your_cool_method, 0, 0, 0
=> 0

# More detailed log
>>
  spy(object).received_messages.any? do|m|
    m.method_name == :your_cool_method && m.arguments.all? {|arg| arg.is_a? Integer }
  end
=> true

>> last_method_call = spy(object).received_messages.last
>>
  last_method_call.method_name == :your_finalizer &&
    p(last_method_call.arguments) == ['resource to release']
=> true
```

### Stub Methods of a Spy

### Stub Methods of a Double

## Contributing

1. Fork it ( https://github.com/igrep/crispy/fork )
2. Create your feature branch (`git checkout -b your-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin your-new-feature`)
5. Create a new Pull Request
