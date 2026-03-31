# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.7] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.2.6] - 2026-03-26

### Changed
- Add Sponsor badge to README
- Fix License section format
- Sync gemspec summary with README


## [0.2.5] - 2026-03-24

### Fixed
- Align README one-liner with gemspec summary

## [0.2.4] - 2026-03-24

### Fixed
- Remove inline comments from Development section to match template

## [0.2.3] - 2026-03-22

### Added
- Expand test coverage to 30+ examples with edge cases for float casting, boolean case insensitivity, multiple errors, optional vars, default precedence, required with default

## [0.2.2] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

## [0.2.2] - 2026-03-21

### Fixed
- Standardize Installation section in README

## [0.2.1] - 2026-03-16

### Changed
- Add License badge to README
- Add bug_tracker_uri to gemspec

## [0.2.0] - 2026-03-13

### Added
- `choices:` option for enum/allowlist validation on all schema types
- `Result#keys` method to list all defined variable names
- `Result#key?` method to check if a variable was defined
- `Result#slice` method to return a subset hash of specific keys

## [0.1.0] - 2026-03-10

### Added
- Initial release
- Schema DSL with `string`, `integer`, `float`, and `boolean` types
- Required/optional variables with defaults
- Type casting with clear error messages
- Boolean parsing (true/false/1/0/yes/no/on/off)
- Typed `Result` object with `fetch` and `[]` accessors
