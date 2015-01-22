source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-crispy.gemspec
gemspec

gem 'codeclimate-test-reporter', require: nil if ENV['CODECLIMATE_REPO_TOKEN']

if ENV['USE_CRISPY_IN_THIS_REPOSITORY'] == '1'
  crispy_in_this_repository = "#{File.dirname(File.expand_path(__FILE__))}/../"
  gem 'crispy', path: crispy_in_this_repository
end
