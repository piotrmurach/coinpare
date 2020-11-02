# frozen_string_literal: true

require_relative "lib/coinpare/version"

Gem::Specification.new do |spec|
  spec.name          = "coinpare"
  spec.license       = "AGPL-3.0"
  spec.version       = Coinpare::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = %q{Compare cryptocurrency trading data across multiple exchanges and blockchains.}
  spec.description   = %q{Compare cryptocurrency trading data across multiple exchanges and blockchains.}
  spec.homepage      = "https://github.com/piotrmurach/coinpare"

  spec.files         = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.bindir        = "exe"
  spec.executables   = ["coinpare"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "tty-config", "~> 0.4.0"
  spec.add_dependency "tty-cursor", "~> 0.7"
  spec.add_dependency "tty-editor", "~> 0.6"
  spec.add_dependency "tty-font", "~> 0.5"
  spec.add_dependency "tty-pager", "~> 0.14"
  spec.add_dependency "tty-pie", "~> 0.4.0"
  spec.add_dependency "tty-prompt", "~> 0.22"
  spec.add_dependency "tty-spinner", "~> 0.9"
  spec.add_dependency "tty-table", "~> 0.12.0"
  spec.add_dependency "pastel", "~> 0.8.0"
  spec.add_dependency "thor", "~> 1.0.1"
  spec.add_dependency "toml", "~> 0.2.0"
  spec.add_dependency "timers", "~> 4.1.2"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.5"
  spec.add_development_dependency "timecop", "~> 0.9.1"
end
