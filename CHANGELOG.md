# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
