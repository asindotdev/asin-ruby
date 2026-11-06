# frozen_string_literal: true

require_relative "lib/asin/version"

Gem::Specification.new do |spec|
  spec.name = "asindotdev"
  spec.version = Asin::VERSION
  spec.authors = ["Asin"]
  spec.email = ["contact@asin.dev"]

  spec.summary = "Official Ruby SDK for the Asin Amazon price tracking API."
  spec.description = "Track Amazon prices and products with a scheduled watchlist, price history, offers and alerts."
  spec.homepage = "https://www.asin.dev"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/asindotdev/asin-ruby/issues",
    "documentation_uri" => "https://www.asin.dev/docs",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/asindotdev/asin-ruby"
  }

  spec.files = Dir["LICENSE", "README.md", "examples/**/*", "lib/**/*.rb", "sig/**/*.rbs"]
  spec.require_paths = ["lib"]
end
