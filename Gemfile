source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in processable.gemspec.
gemspec

group :development do
  gem 'sqlite3'
end

group :development do
  gem 'puma'
end

group :test do
  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  gem 'pry-rails'
  gem "guard"
  gem "guard-minitest"
end

gem 'byebug', group: [:development, :test]
