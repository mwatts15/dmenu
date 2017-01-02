# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "markw-dmenu"
  spec.version       = "1.1.0"
  spec.authors       = ["Mark Watts"]
  spec.email         = ["wattsmark2015@gmail.com"]
  spec.summary       = %q{A set of utilites for working with the dmenu command line tool.}
  spec.homepage      = "http://github.com/mwatts15/dmenu"
  spec.license       = "MPL-2.0"
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "markw-wcwidth", "~> 0.0.3"
end
