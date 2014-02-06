namespace :test do
  require 'rspec/core/rake_task'

  desc "Run Unit tests"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern    = "spec/**/test_*.rb"
    t.rspec_opts = %w[ --color -Ilib -Ispec]
  end

end
task :test => [:"test:unit"]
