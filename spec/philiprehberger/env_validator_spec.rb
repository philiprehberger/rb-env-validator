# frozen_string_literal: true

require "spec_helper"

RSpec.describe Philiprehberger::EnvValidator do
  it "has a version number" do
    expect(Philiprehberger::EnvValidator::VERSION).not_to be_nil
  end

  describe ".define" do
    it "validates and returns typed values" do
      env = { "PORT" => "3000", "HOST" => "localhost" }

      result = described_class.define(env: env) do
        integer :PORT, required: true
        string :HOST, required: true
      end

      expect(result[:PORT]).to eq(3000)
      expect(result[:HOST]).to eq("localhost")
    end

    it "applies defaults for missing values" do
      result = described_class.define(env: {}) do
        integer :PORT, default: 8080
        string :HOST, default: "0.0.0.0"
        boolean :DEBUG, default: false
      end

      expect(result[:PORT]).to eq(8080)
      expect(result[:HOST]).to eq("0.0.0.0")
      expect(result[:DEBUG]).to be false
    end

    it "raises ValidationError for missing required variables" do
      expect do
        described_class.define(env: {}) do
          string :DATABASE_URL, required: true
          string :API_KEY, required: true
        end
      end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /DATABASE_URL.*API_KEY/)
    end

    it "casts boolean values" do
      %w[true 1 yes on].each do |val|
        result = described_class.define(env: { "FLAG" => val }) do
          boolean :FLAG
        end
        expect(result[:FLAG]).to be(true), "Expected #{val.inspect} to cast to true"
      end

      %w[false 0 no off].each do |val|
        result = described_class.define(env: { "FLAG" => val }) do
          boolean :FLAG
        end
        expect(result[:FLAG]).to be(false), "Expected #{val.inspect} to cast to false"
      end
    end

    it "raises CastError for invalid integer" do
      expect do
        described_class.define(env: { "PORT" => "abc" }) do
          integer :PORT
        end
      end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Cannot cast PORT/)
    end

    it "raises CastError for invalid boolean" do
      expect do
        described_class.define(env: { "FLAG" => "maybe" }) do
          boolean :FLAG
        end
      end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Cannot cast FLAG/)
    end

    it "casts float values" do
      result = described_class.define(env: { "RATE" => "3.14" }) do
        float :RATE
      end

      expect(result[:RATE]).to be_within(0.001).of(3.14)
    end

    it "treats empty strings as missing" do
      result = described_class.define(env: { "HOST" => "" }) do
        string :HOST, default: "localhost"
      end

      expect(result[:HOST]).to eq("localhost")
    end

    context "with choices option" do
      it "accepts a valid choice" do
        result = described_class.define(env: { "ENV" => "production" }) do
          string :ENV, choices: %w[production staging development]
        end

        expect(result[:ENV]).to eq("production")
      end

      it "raises ValidationError for an invalid choice" do
        expect do
          described_class.define(env: { "ENV" => "invalid" }) do
            string :ENV, choices: %w[production staging]
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /must be one of: production, staging/)
      end

      it "works with integer choices" do
        result = described_class.define(env: { "LEVEL" => "3" }) do
          integer :LEVEL, choices: [1, 2, 3]
        end

        expect(result[:LEVEL]).to eq(3)
      end
    end
  end
end

RSpec.describe Philiprehberger::EnvValidator::Result do
  subject(:result) { described_class.new({ "PORT" => 3000, "HOST" => "localhost" }) }

  describe "#fetch" do
    it "returns the value" do
      expect(result.fetch(:PORT)).to eq(3000)
    end

    it "raises KeyError for unknown keys" do
      expect { result.fetch(:UNKNOWN) }.to raise_error(KeyError)
    end
  end

  describe "#[]" do
    it "is an alias for fetch" do
      expect(result[:HOST]).to eq("localhost")
    end
  end

  describe "#keys" do
    it "returns all defined variable names" do
      expect(result.keys).to contain_exactly("PORT", "HOST")
    end
  end

  describe "#key?" do
    it "returns true for defined variables" do
      expect(result.key?(:PORT)).to be true
    end

    it "returns false for undefined variables" do
      expect(result.key?(:UNKNOWN)).to be false
    end
  end

  describe "#slice" do
    it "returns a subset hash of specific keys" do
      expect(result.slice(:PORT)).to eq({ "PORT" => 3000 })
    end

    it "returns an empty hash for unknown keys" do
      expect(result.slice(:UNKNOWN)).to eq({})
    end
  end

  describe "#to_h" do
    it "returns a copy of all values" do
      hash = result.to_h
      expect(hash).to eq({ "PORT" => 3000, "HOST" => "localhost" })
    end
  end
end
