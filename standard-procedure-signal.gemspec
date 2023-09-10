# frozen_string_literal: true

require_relative "lib/signal"

Gem::Specification.new do |spec|
  spec.name = "standard-procedure-signal"
  spec.version = Signal::VERSION
  spec.authors = ["Rahoul Baruah"]
  spec.email = ["rahoulb@standardprocedure.app"]

  spec.summary = "Observable attributes using the Signal pattern from reactive Javascript"
  spec.description = "Observable attributes which adapt based upon their dependencies so we avoid unecessary updates"
  spec.homepage = "https://theartandscienceofruby.com"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/standard-procedure/standard-procedure-attribute"
  spec.metadata["changelog_uri"] = "https://github.com/standard-procedure/standard-procedure-attribute"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
