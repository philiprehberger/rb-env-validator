# frozen_string_literal: true

module Philiprehberger
  module EnvValidator
    # Validates environment variables against a schema.
    class Validator
      BOOLEAN_TRUE  = %w[true 1 yes on].freeze
      BOOLEAN_FALSE = %w[false 0 no off].freeze

      # @param schema [Schema] the schema to validate against
      # @param env [Hash] the environment hash (default: ENV)
      # @param prefix [String, nil] optional prefix prepended to variable names during lookup
      def initialize(schema, env: ENV, prefix: nil)
        @schema = schema
        @env = env
        @prefix = prefix
      end

      # Validate and return a Result.
      #
      # @return [Result] validated values
      # @raise [ValidationError] if required variables are missing or casting fails
      def validate!
        errors = []
        values = {}

        @schema.definitions.each do |name, definition|
          value, error = resolve(name, definition)
          errors << error if error
          values[name] = value unless error
        end

        raise ValidationError, errors.join('; ') unless errors.empty?

        Result.new(values)
      end

      private

      def resolve(name, definition)
        env_key = @prefix ? "#{@prefix}#{name}" : name
        raw = @env[env_key]

        return resolve_missing(env_key, definition) if raw.nil? || raw.empty?

        value = cast(raw, definition[:type], env_key)
        validate_choices(env_key, value, definition[:choices])
        [value, nil]
      rescue CastError => e
        [nil, e.message]
      end

      def resolve_missing(env_key, definition)
        if definition[:required] && definition[:default].nil?
          [nil, "Missing required variable: #{env_key}"]
        else
          [definition[:default], nil]
        end
      end

      def validate_choices(name, value, choices)
        return if choices.nil? || choices.include?(value)

        raise CastError, "#{name} must be one of: #{choices.join(', ')}"
      end

      def cast(value, type, name)
        case type
        when :string  then value
        when :integer then Integer(value)
        when :float   then Float(value)
        when :boolean then cast_boolean(value, name)
        else raise CastError, "Unknown type #{type} for #{name}"
        end
      rescue ArgumentError
        raise CastError, "Cannot cast #{name}=#{value.inspect} to #{type}"
      end

      def cast_boolean(value, name)
        downcased = value.downcase
        return true if BOOLEAN_TRUE.include?(downcased)
        return false if BOOLEAN_FALSE.include?(downcased)

        raise CastError, "Cannot cast #{name}=#{value.inspect} to boolean (use true/false/1/0/yes/no/on/off)"
      end
    end
  end
end
