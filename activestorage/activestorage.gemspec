# frozen_string_literal: true

version = File.read(File.expand_path("../RAILS_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "activestorage"
  s.version     = version
  s.summary     = "Local and cloud file storage framework."
  s.description = "Attach cloud and local files in Quails applications."

  s.required_ruby_version = ">= 2.2.2"

  s.license = "MIT"

  s.author   = "David Heinemeier Hansson"
  s.email    = "david@loudthinking.com"
  s.homepage = "http://rubyonquails.org"

  s.files        = Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "lib/**/*", "app/**/*", "config/**/*"]
  s.require_path = "lib"

  s.metadata = {
    "source_code_uri" => "https://github.com/quails/quails/tree/v#{version}/activestorage",
    "changelog_uri"   => "https://github.com/quails/quails/blob/v#{version}/activestorage/CHANGELOG.md"
  }

  s.add_dependency "actionpack", version
  s.add_dependency "activerecord", version
end
