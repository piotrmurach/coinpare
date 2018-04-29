lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "coinpare/version"

Gem::Specification.new do |spec|
  spec.name          = "coinpare"
  spec.license       = "AGPL-3.0"
  spec.version       = Coinpare::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = [""]

  spec.summary       = %q{Compare cryptocurrency trading data across multiple exchanges and blockchains.}
  spec.description   = %q{Compare cryptocurrency trading data across multiple exchanges and blockchains.}
  spec.homepage      = "https://github.com/piotrmurach/coinpare"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-color", "~> 0.4.2"
  spec.add_dependency "tty-command", "~> 0.7.0"
  spec.add_dependency "tty-config", "~> 0.1.0"
  spec.add_dependency "tty-cursor", "~> 0.5.0"
  spec.add_dependency "tty-editor", "~> 0.4.0"
  #spec.add_dependency "tty-file", "~> 0.5.0"
  spec.add_dependency "tty-font", "~> 0.2.0"
  spec.add_dependency "tty-markdown", "~> 0.3.0"
  spec.add_dependency "tty-pager", "~> 0.11.0"
  spec.add_dependency "tty-prompt", "~> 0.16.0"
  spec.add_dependency "tty-screen", "~> 0.6.4"
  spec.add_dependency "tty-spinner", "~> 0.8.0"
  spec.add_dependency "tty-table", "~> 0.10.0"
  spec.add_dependency "tty-tree", "~> 0.1.0"
  spec.add_dependency "pastel", "~> 0.7.2"
  spec.add_dependency "thor", "~> 0.20.0"
  spec.add_dependency "toml", "~> 0.2.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.3"
  spec.add_development_dependency "timecop", "~> 0.9.1"
end
