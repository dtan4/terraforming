source 'https://rubygems.org'

# Specify your gem's dependencies in terraforming.gemspec
gemspec

group :development do
  gem "guard"
  gem "guard-rspec"

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.2.0")
    gem "listen", "~> 3.1.0"
  else
    gem "listen", "< 3.1.0"
  end

  gem "rubocop"

  gem "terminal-notifier-guard"
end
