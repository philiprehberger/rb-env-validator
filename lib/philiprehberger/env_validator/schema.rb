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
      def string(name, required: false, default: nil)
        @definitions[name.to_s] = { type: :string, required: required, default: default }
      end

      # Define an integer variable.
      #
      # @param name [Symbol, String] the ENV variable name
      # @param required [Boolean] whether the variable is required
      # @param default [Integer, nil] default value if not set
      # @return [void]
      def integer(name, required: false, default: nil)
        @definitions[name.to_s] = { type: :integer, required: required, default: default }
      end

      # Define a float variable.
      #
      # @param name [Symbol, String] the ENV variable name
      # @param required [Boolean] whether the variable is required
      # @param default [Float, nil] default value if not set
      # @return [void]
      def float(name, required: false, default: nil)
        @definitions[name.to_s] = { type: :float, required: required, default: default }
      end

      # Define a boolean variable.
      #
      # @param name [Symbol, String] the ENV variable name
      # @param required [Boolean] whether the variable is required
      # @param default [Boolean, nil] default value if not set
      # @return [void]
      def boolean(name, required: false, default: nil)
        @definitions[name.to_s] = { type: :boolean, required: required, default: default }
      end
    end
  end
end
