# philiprehberger-env_validator

[![Tests](https://github.com/philiprehberger/rb-env-validator/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-env-validator/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-env_validator.svg)](https://rubygems.org/gems/philiprehberger-env_validator)

Schema-based environment variable validation with typed accessors for Ruby.

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-env_validator"
```

Then run:

```bash
bundle install
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
| `Result#to_h` | Get all values as a hash |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
