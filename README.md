# Crispy

Minimalistic test double library in Ruby - only privides Spy and Stub!

But sorry, there're MANY features **not actually implemented**!

## Features

- Less intrusive. Never directly changes other objects behavior: It just wraps them and spies/stubs their methods.
    - **NOTE**: So remember, you have to pass the spy/stub objects to your methods or call your methods of the spy/stub objects.
        NOT your objects you want to spy or stub their methods.
        See the Usage below for details.
- Extremely flexible query for spied (`have_received`) messages with `spied_messages` method.

## Installation

Add this line to your application's Gemfile:

    gem 'crispy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crispy

## Usage

### Spy on a Object

```ruby
object = YourCoolClass.new
spy = Crispy.spy_on object

# NOTE: Call method through the spy object, instead of YourCoolClass's instance itself.
spy.your_cool_method 1, 2, 3
spy.your_method_without_argument
spy.your_lovely_method 'great', 'arguments'
spy.your_lovely_method 'great', 'arguments', 'again'
spy.your_finalizer 'resource to release'

# No arguments
spy.spied? :your_cool_method # => true
spy.spied? :your_method_without_argument # => true
spy.spied? :your_lovely_method # => true
spy.spied? :your_ugly_method # => false

# With arguments (each argument is compared by == method)
spy.spied? :your_cool_method 1, 2, 3 # => true
spy.spied? :your_cool_method 0, 0, 0 # => false
spy.spied? :your_method_without_argument, :not, :given, :arguments # => false
spy.spied? :your_lovely_method 'great', 'arguments' # => true
spy.spied? :your_ugly_method, 'off course', 'I gave no arguments' # => false

# With arguments and block
### Sorry, I'm still thinking of the specification for that case ###

# Count method calls
spy.count_spied :your_cool_method # => 1
spy.count_spied :your_cool_method 1, 2, 3 # => 1
spy.count_spied :your_cool_method 0, 0, 0 # => 0

# More detailed log
spy.spied_messages.any? do|m|
  m.method_name == :your_cool_method \
    && m.arguments.all {|arg| arg.is_a? Integer }
end
  # => true
last_method_call = spy.spied_messages.last
last_method_call.method_name == :your_finalizer \
  && last_method_call.arguments == ['resource to release']
  # => true
```

## Contributing

1. Fork it ( https://github.com/igrep/crispy/fork )
2. Create your feature branch (`git checkout -b your-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin your-new-feature`)
5. Create a new Pull Request
