# frozen_string_literal: true

module Philiprehberger
  module EnvValidator
    # Holds validated environment values with typed accessors.
    class Result
      # @param values [Hash<String, Object>] validated and cast values
      def initialize(values)
        @values = values
      end

      # Fetch a validated value by name.
      #
      # @param name [Symbol, String] the variable name
      # @return the cast value
      # @raise [KeyError] if the name was not defined in the schema
      def fetch(name)
        key = name.to_s
        raise KeyError, "Unknown variable: #{key}" unless @values.key?(key)

        @values[key]
      end

      alias_method :[], :fetch

      # @return [Hash<String, Object>] all validated values
      def to_h
        @values.dup
      end
    end
  end
end
