source "https://rubygems.org"

gemspec

group :test do
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.5.0")
    gem "coveralls_reborn", "~> 0.22.0"
    gem "simplecov", "~> 0.21.0"
  end
end
