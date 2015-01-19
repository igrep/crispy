require "bundler/gem_tasks"

task :test do
  # split spec execution by whether overwrite rspec-mock's API or not. see `git show f460ae689692a8b1c667f1a8f40e815f51aa91df`.
  sh 'bundle exec rspec spec/rspec/crispy/configure_without_conflict_spec.rb'
  sh 'bundle exec rspec spec/rspec/crispy/mock_with_rspec_crispy_spec.rb'
end
