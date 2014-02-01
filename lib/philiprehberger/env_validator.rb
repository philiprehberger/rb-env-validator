# frozen_string_literal: true

require_relative "env_validator/version"
require_relative "env_validator/schema"
require_relative "env_validator/result"
require_relative "env_validator/validator"

module Philiprehberger
  module EnvValidator
    class Error < StandardError; end

    # Raised when validation fails.
    class ValidationError < Error; end

    # Raised when a value cannot be cast to the expected type.
    class CastError < Error; end

    # Define and validate environment variables.
    #
    # @param env [Hash] the environment hash (default: ENV)
    # @yield [schema] configure the schema
    # @yieldparam schema [Schema]
    # @return [Result] validated values
    # @raise [ValidationError] if validation fails
    def self.define(env: ENV, &block)
      schema = Schema.new
      schema.instance_eval(&block)
      Validator.new(schema, env: env).validate!
    end
  end
end
