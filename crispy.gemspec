lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crispy/version'

Gem::Specification.new do |spec|
  spec.name          = "crispy"
  spec.version       = Crispy::VERSION
  spec.authors       = ["Yamamoto Yuji"]
  spec.email         = ["whosekiteneverfly@gmail.com"]
  spec.summary       = %q{Test spy for any object.}
  spec.description   =
    "Test spy for any object.\n" \
    "It makes mocks obsolete so you don't have to be worried about " \
    "where to put the expectations (i.e. before or after the subject method)."
  spec.homepage      = "https://github.com/igrep/crispy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.4"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "byebug"

  spec.required_ruby_version = '>= 2.0'
end
