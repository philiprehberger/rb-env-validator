# frozen_string_literal: true

module Philiprehberger
  module EnvValidator
    # Validates environment variables against a schema.
    class Validator
      BOOLEAN_TRUE  = %w[true 1 yes on].freeze
      BOOLEAN_FALSE = %w[false 0 no off].freeze

      # @param schema [Schema] the schema to validate against
      # @param env [Hash] the environment hash (default: ENV)
      def initialize(schema, env: ENV)
        @schema = schema
        @env = env
      end

      # Validate and return a Result.
      #
      # @return [Result] validated values
      # @raise [ValidationError] if required variables are missing or casting fails
      def validate!
        errors = []
        values = {}

        @schema.definitions.each do |name, definition|
          raw = @env[name]

          if raw.nil? || raw.empty?
            if definition[:required] && definition[:default].nil?
              errors << "Missing required variable: #{name}"
              next
            end

            values[name] = definition[:default]
            next
          end

          begin
            values[name] = cast(raw, definition[:type], name)
          rescue CastError => e
            errors << e.message
          end
        end

        raise ValidationError, errors.join("; ") unless errors.empty?

        Result.new(values)
      end

      private

      def cast(value, type, name)
        case type
        when :string
          value
        when :integer
          Integer(value)
        when :float
          Float(value)
        when :boolean
          cast_boolean(value, name)
        else
          raise CastError, "Unknown type #{type} for #{name}"
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
