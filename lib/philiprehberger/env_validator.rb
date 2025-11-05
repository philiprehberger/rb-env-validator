# frozen_string_literal: true

require_relative 'env_validator/version'
require_relative 'env_validator/schema'
require_relative 'env_validator/result'
require_relative 'env_validator/validator'

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
    # @param prefix [String, nil] optional prefix prepended to variable names during lookup
    # @yield [schema] configure the schema
    # @yieldparam schema [Schema]
    # @return [Result] validated values
    # @raise [ValidationError] if validation fails
    def self.define(env: ENV, prefix: nil, &block)
      schema = Schema.new
      schema.instance_eval(&block)
      Validator.new(schema, env: env, prefix: prefix).validate!
    end
  end
end
