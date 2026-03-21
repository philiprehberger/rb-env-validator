# philiprehberger-env_validator

[![Tests](https://github.com/philiprehberger/rb-env-validator/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-env-validator/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-env_validator.svg)](https://rubygems.org/gems/philiprehberger-env_validator)
[![License](https://img.shields.io/github/license/philiprehberger/rb-env-validator)](LICENSE)

Schema-based environment variable validation with typed accessors for Ruby

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-env_validator"
```

Or install directly:

```bash
gem install philiprehberger-env_validator
```

## Usage

```ruby
require "philiprehberger/env_validator"

config = Philiprehberger::EnvValidator.define do
  string  :DATABASE_URL, required: true
  integer :PORT, default: 3000
  boolean :FEATURE_FLAG, default: false
  float   :RATE_LIMIT, default: 1.5
end

config[:DATABASE_URL]   # => "postgres://..."
config[:PORT]           # => 3000 (integer)
config[:FEATURE_FLAG]   # => false (boolean)
```

### Custom ENV Hash

```ruby
# Useful for testing
env = { "PORT" => "8080", "DEBUG" => "true" }

config = Philiprehberger::EnvValidator.define(env: env) do
  integer :PORT, required: true
  boolean :DEBUG, default: false
end

config[:PORT]  # => 8080
config[:DEBUG] # => true
```

### Choices (Allowlist)

```ruby
config = Philiprehberger::EnvValidator.define(env: { "RAILS_ENV" => "production" }) do
  string :RAILS_ENV, required: true, choices: %w[production staging development]
  integer :LOG_LEVEL, default: 1, choices: [0, 1, 2, 3]
end

config[:RAILS_ENV] # => "production"
```

If the value is not in the allowed list, a `ValidationError` is raised.

### Result Methods

```ruby
config = Philiprehberger::EnvValidator.define(env: { "PORT" => "3000", "HOST" => "localhost" }) do
  integer :PORT, required: true
  string :HOST, required: true
end

config.keys            # => ["PORT", "HOST"]
config.key?(:PORT)     # => true
config.slice(:PORT)    # => { "PORT" => 3000 }
```

### Validation Errors

```ruby
# Raises ValidationError with all errors at once
Philiprehberger::EnvValidator.define do
  string :DATABASE_URL, required: true
  string :API_KEY, required: true
end
# => Philiprehberger::EnvValidator::ValidationError:
#    Missing required variable: DATABASE_URL; Missing required variable: API_KEY
```

### Supported Types

| Type | Method | Accepts |
|------|--------|---------|
| String | `string` | Any value |
| Integer | `integer` | Numeric strings (`"42"`, `"-1"`) |
| Float | `float` | Numeric strings (`"3.14"`, `"1"`) |
| Boolean | `boolean` | `true/false/1/0/yes/no/on/off` (case-insensitive) |

## API

| Method / Class | Description |
|----------------|-------------|
| `EnvValidator.define(env:, &block)` | Define schema and validate |
| `Result#fetch(name)` / `Result#[name]` | Get a validated value |
| `Result#keys` | List all defined variable names |
| `Result#key?(name)` | Check if a variable was defined |
| `Result#slice(*names)` | Get a subset hash of specific keys |
| `Result#to_h` | Get all values as a hash |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
