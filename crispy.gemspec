lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crispy/version'

Gem::Specification.new do |spec|
  spec.name          = "crispy"
  spec.version       = Crispy::VERSION
  spec.authors       = ["Yamamoto Yuji"]
  spec.email         = ["whosekiteneverfly@gmail.com"]
  spec.summary       = %q{Test spy and stub for any object in Ruby.}
  spec.description   = %q{Test spy and stub for any object in Ruby. Independent from any testing framework.}
  spec.homepage      = "https://github.com/igrep/crispy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rubydoctest"

  spec.required_ruby_version = '>= 2.0'
end
