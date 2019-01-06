source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

gem 'tty-pie', git: 'https://github.com/piotrmurach/tty-pie'

group :test do
  gem 'simplecov', '~> 0.16.1'
end

group :metrics do
  gem 'yard',      '~> 0.9.12'
  gem 'yardstick', '~> 0.9.9'
end
