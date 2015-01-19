# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/crispy/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-crispy"
  spec.version       = RSpec::Crispy::VERSION
  spec.authors       = ["Yamamoto Yuji"]
  spec.email         = ["whosekiteneverfly@gmail.com"]
  spec.summary       = %q{RSpec plugin for Crispy you can use with rspec-mocks.}
  spec.description   = %q{RSpec plugin for Crispy you can use with rspec-mocks. Privides matchers such as have_received to use Crispy's API in RSpec's way.}
  spec.homepage      = "https://github.com/igrep/rspec-crispy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{\Aspec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "crispy", ">= 0.3.2"
end
