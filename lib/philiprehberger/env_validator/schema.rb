# frozen_string_literal: true

module Philiprehberger
  module EnvValidator
    # Defines the schema for environment variable validation.
    class Schema
      attr_reader :definitions

      def initialize
        @definitions = {}
      end

      # Define a string variable.
      #
      # @param name [Symbol, String] the ENV variable name
      # @param required [Boolean] whether the variable is required
      # @param default [String, nil] default value if not set
      # @return [void]
      def string(name, required: false, default: nil, choices: nil)
        @definitions[name.to_s] = { type: :string, required: required, default: default, choices: choices }
      end

      # Define an integer variable.
      #
      # @param name [Symbol, String] the ENV variable name
      # @param required [Boolean] whether the variable is required
      # @param default [Integer, nil] default value if not set
      # @param choices [Array, nil] allowed values
      # @return [void]
      def integer(name, required: false, default: nil, choices: nil)
        @definitions[name.to_s] = { type: :integer, required: required, default: default, choices: choices }
      end

      # Define a float variable.
      #
      # @param name [Symbol, String] the ENV variable name
      # @param required [Boolean] whether the variable is required
      # @param default [Float, nil] default value if not set
      # @param choices [Array, nil] allowed values
      # @return [void]
      def float(name, required: false, default: nil, choices: nil)
        @definitions[name.to_s] = { type: :float, required: required, default: default, choices: choices }
      end

      # Define a boolean variable.
      #
      # @param name [Symbol, String] the ENV variable name
      # @param required [Boolean] whether the variable is required
      # @param default [Boolean, nil] default value if not set
      # @param choices [Array, nil] allowed values
      # @return [void]
      def boolean(name, required: false, default: nil, choices: nil)
        @definitions[name.to_s] = { type: :boolean, required: required, default: default, choices: choices }
      end

      # Define an array variable parsed from a delimited string.
      #
      # The ENV value is split on `separator`, each element is stripped of
      # surrounding whitespace, and each element is cast to `item_type`
      # using the same type caster the other schema methods use.
      #
      # @param name [Symbol, String] the ENV variable name
      # @param item_type [Symbol] element type (:string, :integer, :float, :boolean)
      # @param separator [String] delimiter between elements (default: ',')
      # @param required [Boolean] whether the variable is required
      # @param default [Array, nil] default value if not set
      # @return [void]
      def array(name, item_type: :string, separator: ',', required: false, default: nil)
        @definitions[name.to_s] = {
          type: :array,
          item_type: item_type,
          separator: separator,
          required: required,
          default: default,
          choices: nil
        }
      end
    end
  end
end
