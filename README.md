# philiprehberger-env_validator

[![Tests](https://github.com/philiprehberger/rb-env-validator/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-env-validator/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-env_validator.svg)](https://rubygems.org/gems/philiprehberger-env_validator)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-env-validator)](https://github.com/philiprehberger/rb-env-validator/commits/main)

![philiprehberger-env_validator](https://raw.githubusercontent.com/philiprehberger/rb-env-validator/main/package-card.webp)

Schema-based environment variable validation with typed accessors

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
config.to_h            # => { "PORT" => 3000, "HOST" => "localhost" }

# Redact sensitive keys when serializing (e.g. for logs)
config.to_h(exclude: %i[api_key])
# => { "PORT" => 3000, "HOST" => "localhost" }
```

The `exclude:` list accepts symbols or strings and is matched against keys regardless of how they are stored internally.

### Prefix

Group related variables with a shared prefix:

```ruby
env = { "REDIS_HOST" => "localhost", "REDIS_PORT" => "6379", "REDIS_PASSWORD" => "secret" }

config = Philiprehberger::EnvValidator.define(env: env, prefix: "REDIS_") do
  string  :HOST, required: true
  integer :PORT, default: 6379
  string  :PASSWORD
end

config[:HOST] # => "localhost"
config[:PORT] # => 6379
```

The prefix is prepended when looking up each variable in the environment. Result keys use the short name (without prefix). Error messages include the full prefixed name.

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

### Arrays (Delimited Lists)

Parse a delimited ENV value into an array of typed elements:

```ruby
env = {
  "TAGS"    => "ruby,rails,hotwire",
  "PORTS"   => "3000,3001,3002",
  "PATHS"   => "/usr/bin:/usr/local/bin"
}

config = Philiprehberger::EnvValidator.define(env: env) do
  array :TAGS
  array :PORTS, item_type: :integer
  array :PATHS, separator: ":"
end

config[:TAGS]  # => ["ruby", "rails", "hotwire"]
config[:PORTS] # => [3000, 3001, 3002]
config[:PATHS] # => ["/usr/bin", "/usr/local/bin"]
```

Each element is stripped of surrounding whitespace and cast to `item_type`. An empty or missing ENV value yields `[]` (or the configured `default:`). If any element fails to cast a `ValidationError` is raised.

### Supported Types

| Type | Method | Accepts |
|------|--------|---------|
| String | `string` | Any value |
| Integer | `integer` | Numeric strings (`"42"`, `"-1"`) |
| Float | `float` | Numeric strings (`"3.14"`, `"1"`) |
| Boolean | `boolean` | `true/false/1/0/yes/no/on/off` (case-insensitive) |
| Array | `array` | Delimited string cast to a list of typed elements |

### Immutable Configs

Once validated at boot time, prevent accidental mutation of the result:

```ruby
ENV_CONFIG = Philiprehberger::EnvValidator.define do
  string :api_key
end.freeze!

ENV_CONFIG.fetch(:api_key) << 'tamper'  # => FrozenError
```

## API

| Method / Class | Description |
|----------------|-------------|
| `EnvValidator.define(env:, prefix:, &block)` | Define schema and validate |
| `Schema#array(name, item_type:, separator:, required:, default:)` | Declare a delimited list ENV var parsed into a typed array |
| `Result#fetch(name)` / `Result#[name]` | Get a validated value |
| `Result#keys` | List all defined variable names |
| `Result#key?(name)` | Check if a variable was defined |
| `Result#slice(*names)` | Get a subset hash of specific keys |
| `Result#to_h(exclude:)` | Get all values as a hash; pass `exclude:` to omit keys (symbols or strings) |
| `Result#freeze!` | Deeply freeze the result; returns self for chaining |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-env-validator)

🐛 [Report issues](https://github.com/philiprehberger/rb-env-validator/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-env-validator/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
