# frozen_string_literal: true

require_relative "lib/filesystem_queue/version"

Gem::Specification.new do |spec|
  spec.name = "filesystem_queue"
  spec.version = FilesystemQueue::VERSION
  spec.authors = ["Carlos Westman"]
  spec.email = ["carloswestman@gmail.com"]

  spec.summary = "A persistent queue system based on the local filesystem"
  spec.description = "FilesystemQueue is a Ruby gem that provides a persistent queue system "\
  "using the local filesystem.It allows you to enqueue and dequeue jobs, and keeps track of completed and failed jobs."
  spec.homepage = "https://github.com/carloswestman/filesystem_queue"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/carloswestman/filesystem_queue/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
