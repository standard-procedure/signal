# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

require "opal"
Opal.append_path "lib"
require "opal/rspec/rake_task"
Opal::Config.source_map_enabled = true
Opal::Config.esm = false

Opal::RSpec::RakeTask.new(:opal_spec) do |server, task|
  server.append_path "lib"
  task.default_path = "spec"
  task.requires = ["spec_helper"]
  task.files = FileList["spec/**/*_spec.rb"]
  task.runner = :server
end
