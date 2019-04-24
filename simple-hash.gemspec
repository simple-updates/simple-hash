require_relative "lib/simple/hash"

Gem::Specification.new do |spec|
  spec.name = "simple-hash"
  spec.version = Simple::Hash::VERSION
  spec.authors = ["localhostdotdev"]
  spec.email = ["localhostdotdev@protonmail.com"]
  spec.summary = "typically make JSON into object with accessors"
  spec.homepage = "https://github.com/simple-updates/simple-hash"
  spec.license = "MIT"
  spec.files = `git ls-files`.split("\n")
  spec.require_paths = ["lib"]
  spec.add_dependency "activesupport", "~> 6.0.0beta3"
end
