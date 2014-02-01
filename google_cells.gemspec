# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_cells/version'

Gem::Specification.new do |spec|
  spec.name          = "google-cells"
  spec.version       = GoogleCells::VERSION
  spec.authors       = ["Jessica Megan Thrower"]
  spec.email         = ["jmthrower@gmail.com"]
  spec.summary       = %q{Google Spreadsheets API wrapper}
  spec.description   = %q{An intuitive Google Spreadsheets API wrapper}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency 'rake', '~> 0'
  spec.add_development_dependency 'google-api-client', '~> 0.7', '>= 0.7.1'
end
