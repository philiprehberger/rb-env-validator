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

      alias [] fetch

      # @return [Array<String>] all defined variable names
      def keys
        @values.keys
      end

      # Check if a variable was defined in the schema.
      #
      # @param name [Symbol, String] the variable name
      # @return [Boolean]
      def key?(name)
        @values.key?(name.to_s)
      end

      # Return a subset hash of specific keys.
      #
      # @param names [Array<Symbol, String>] the variable names to include
      # @return [Hash<String, Object>]
      def slice(*names)
        string_keys = names.map(&:to_s)
        @values.slice(*string_keys)
      end

      # Return all validated values as a hash, optionally redacting keys.
      #
      # @param exclude [Array<Symbol, String>] keys to omit from the returned hash
      # @return [Hash<String, Object>] all validated values, minus excluded keys
      def to_h(exclude: [])
        return @values.dup if exclude.nil? || exclude.empty?

        excluded_keys = exclude.map(&:to_s)
        @values.reject { |key, _| excluded_keys.include?(key.to_s) }
      end

      # Deeply freeze the result so it cannot be mutated after validation.
      #
      # Freezes the underlying values hash, all string keys, and any String
      # values it holds. Useful for global/shared ENV configs that should be
      # immutable after boot.
      #
      # @return [Result] self
      def freeze!
        @values.each_value { |v| v.freeze if v.is_a?(String) && !v.frozen? }
        @values.freeze
        self
      end
    end
  end
end
