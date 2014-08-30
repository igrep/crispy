# Crispy

[![Code Climate](https://codeclimate.com/github/igrep/crispy/badges/gpa.svg)](https://codeclimate.com/github/igrep/crispy)
[![Test Coverage](https://codeclimate.com/github/igrep/crispy/badges/coverage.svg)](https://codeclimate.com/github/igrep/crispy)
[![Build Status](https://travis-ci.org/igrep/crispy.svg?branch=master)](https://travis-ci.org/igrep/crispy)
[![Gem Version](https://badge.fury.io/rb/crispy.svg)](http://badge.fury.io/rb/crispy)

Test Spy for Any Object in Ruby.

## Features

- Test spy for any object by using `prepend` (Sorry, it runs by Ruby 2.0 or higher!)
- Extremely flexible query for received messages with `received_messages` method.
    - By using Array and Enumerable's methods, you never have to remember the complex API and tons of the argument matchers in RSpec anymore!
- Makes mocks obsolete so you don't have to be worried about where to put the expectations (i.e. *before or after the subject method*).

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
```

#### Spy methods with no arguments

Call query methods through the spy object, instead of YourCoolClass's instance.

```ruby
>> spy(object).received? :your_cool_method
=> true
>> spy(object).received? :your_method_without_argument
=> true
>> spy(object).received? :your_lovely_method
=> true
>> spy(object).received? :your_ugly_method
=> false
```

#### Spy methods with arguments

Each argument is compared by `==` method.

```ruby
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
```

#### Spy methods with arguments and a block

*Sorry, I'm still thinking of the specification for that case.*

#### Count method calls

```ruby
>> spy(object).count_received :your_cool_method
=> 1
>> spy(object).count_received :your_cool_method, 1, 2, 3
=> 1
>> spy(object).count_received :your_cool_method, 0, 0, 0
=> 0
```

#### Get more detailed log

You can check arbitrary received methods with the familliar Array's (and of course including Enumerable's!) methods such as `any?`, `all`, `first`, `[]`, `index`.
Because `spy(object).received_messages` returns an array of `Crispy::ReceivedMessage` instances.
**You don't have to remember the tons of matchers for received arguments any more!!**

```ruby
>>
  spy(object).received_messages.any? do|m|
    m.method_name == :your_cool_method && m.arguments.all? {|arg| arg.is_a? Integer }
  end
=> true

>> last_method_call = spy(object).received_messages.last
>>
  last_method_call.method_name == :your_finalizer &&
    last_method_call.arguments == ['resource to release']
=> true
```

### Stub Methods of a Spy

```ruby
>> spy(object).stub(:your_cool_method, 'Awesome!')
>> object.your_cool_method
=> "Awesome!"

>> spy(object).stub(your_lovely_method: 'I love this method!', your_finalizer: 'Finalized!')
>> object.your_lovely_method
=> "I love this method!"
>> object.your_finalizer
=> "Finalized!"
```

### Stub Methods of a Double

```ruby
>> your_awesome_double = double('your awesome double', nice!: '+1!', sexy?: true)
>> your_awesome_double.nice!
=> "+1!"
>> your_awesome_double.sexy?
=> true

>> your_awesome_double.stub(:another_method, 'can be stubbed.')
>> your_awesome_double.another_method
=> "can be stubbed."
```

## Contributing

1. Fork it ( https://github.com/igrep/crispy/fork )
2. Create your feature branch (`git checkout -b your-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin your-new-feature`)
5. Create a new Pull Request
