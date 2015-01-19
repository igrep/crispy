# RSpec::Crispy

Custom matchers for RSpec to call [Crispy](https://github.com/igrep/crispy)'s API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-crispy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-crispy

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/igrep/rspec-crispy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### NOTICE for Contributors

You must use `rake test` to run `rspec spec/rspec/crispy/configure_without_conflict_spec.rb` and `rspec spec/rspec/crispy/mock_with_rspec_crispy_spec.rb` separately.  
Do NOT run all specs at once by `rspec spec`.  
