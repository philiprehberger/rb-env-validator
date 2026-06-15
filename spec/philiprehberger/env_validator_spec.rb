# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::EnvValidator do
  it 'has a version number' do
    expect(Philiprehberger::EnvValidator::VERSION).not_to be_nil
  end

  describe '.define' do
    it 'validates and returns typed values' do
      env = { 'PORT' => '3000', 'HOST' => 'localhost' }

      result = described_class.define(env: env) do
        integer :PORT, required: true
        string :HOST, required: true
      end

      expect(result[:PORT]).to eq(3000)
      expect(result[:HOST]).to eq('localhost')
    end

    it 'applies defaults for missing values' do
      result = described_class.define(env: {}) do
        integer :PORT, default: 8080
        string :HOST, default: '0.0.0.0'
        boolean :DEBUG, default: false
      end

      expect(result[:PORT]).to eq(8080)
      expect(result[:HOST]).to eq('0.0.0.0')
      expect(result[:DEBUG]).to be false
    end

    it 'raises ValidationError for missing required variables' do
      expect do
        described_class.define(env: {}) do
          string :DATABASE_URL, required: true
          string :API_KEY, required: true
        end
      end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /DATABASE_URL.*API_KEY/)
    end

    it 'casts boolean values' do
      %w[true 1 yes on].each do |val|
        result = described_class.define(env: { 'FLAG' => val }) do
          boolean :FLAG
        end
        expect(result[:FLAG]).to be(true), "Expected #{val.inspect} to cast to true"
      end

      %w[false 0 no off].each do |val|
        result = described_class.define(env: { 'FLAG' => val }) do
          boolean :FLAG
        end
        expect(result[:FLAG]).to be(false), "Expected #{val.inspect} to cast to false"
      end
    end

    it 'raises CastError for invalid integer' do
      expect do
        described_class.define(env: { 'PORT' => 'abc' }) do
          integer :PORT
        end
      end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Cannot cast PORT/)
    end

    it 'raises CastError for invalid boolean' do
      expect do
        described_class.define(env: { 'FLAG' => 'maybe' }) do
          boolean :FLAG
        end
      end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Cannot cast FLAG/)
    end

    it 'casts float values' do
      result = described_class.define(env: { 'RATE' => '3.14' }) do
        float :RATE
      end

      expect(result[:RATE]).to be_within(0.001).of(3.14)
    end

    it 'treats empty strings as missing' do
      result = described_class.define(env: { 'HOST' => '' }) do
        string :HOST, default: 'localhost'
      end

      expect(result[:HOST]).to eq('localhost')
    end

    context 'with choices option' do
      it 'accepts a valid choice' do
        result = described_class.define(env: { 'ENV' => 'production' }) do
          string :ENV, choices: %w[production staging development]
        end

        expect(result[:ENV]).to eq('production')
      end

      it 'raises ValidationError for an invalid choice' do
        expect do
          described_class.define(env: { 'ENV' => 'invalid' }) do
            string :ENV, choices: %w[production staging]
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /must be one of: production, staging/)
      end

      it 'works with integer choices' do
        result = described_class.define(env: { 'LEVEL' => '3' }) do
          integer :LEVEL, choices: [1, 2, 3]
        end

        expect(result[:LEVEL]).to eq(3)
      end

      it 'rejects invalid integer choice' do
        expect do
          described_class.define(env: { 'LEVEL' => '5' }) do
            integer :LEVEL, choices: [1, 2, 3]
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /must be one of/)
      end
    end

    context 'with float values' do
      it 'casts integer-like strings to float' do
        result = described_class.define(env: { 'RATE' => '42' }) do
          float :RATE
        end

        expect(result[:RATE]).to eq(42.0)
        expect(result[:RATE]).to be_a(Float)
      end

      it 'raises CastError for non-numeric float' do
        expect do
          described_class.define(env: { 'RATE' => 'abc' }) do
            float :RATE
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Cannot cast RATE/)
      end
    end

    it 'handles boolean case insensitivity' do
      %w[TRUE True YES Yes ON On].each do |val|
        result = described_class.define(env: { 'FLAG' => val }) do
          boolean :FLAG
        end
        expect(result[:FLAG]).to be(true), "Expected #{val.inspect} to cast to true"
      end
    end

    it 'collects multiple errors for multiple missing required vars' do
      expect do
        described_class.define(env: {}) do
          string :A, required: true
          string :B, required: true
          string :C, required: true
        end
      end.to raise_error(Philiprehberger::EnvValidator::ValidationError) { |e|
        expect(e.message).to include('A')
        expect(e.message).to include('B')
        expect(e.message).to include('C')
      }
    end

    it 'does not raise for optional variables missing from env' do
      result = described_class.define(env: {}) do
        string :OPTIONAL_VAR
      end

      expect(result[:OPTIONAL_VAR]).to be_nil
    end

    it 'uses default when variable is not present' do
      result = described_class.define(env: {}) do
        string :HOST, default: 'default-host'
      end

      expect(result[:HOST]).to eq('default-host')
    end

    it 'prefers env value over default' do
      result = described_class.define(env: { 'HOST' => 'env-host' }) do
        string :HOST, default: 'default-host'
      end

      expect(result[:HOST]).to eq('env-host')
    end

    it 'required with default does not raise when missing' do
      result = described_class.define(env: {}) do
        string :HOST, required: true, default: 'fallback'
      end

      expect(result[:HOST]).to eq('fallback')
    end

    context 'with prefix option' do
      it 'looks up prefixed variable names in env' do
        env = { 'REDIS_HOST' => 'localhost', 'REDIS_PORT' => '6379' }

        result = described_class.define(env: env, prefix: 'REDIS_') do
          string  :HOST, required: true
          integer :PORT, required: true
        end

        expect(result[:HOST]).to eq('localhost')
        expect(result[:PORT]).to eq(6379)
      end

      it 'applies defaults when prefixed variable is missing' do
        result = described_class.define(env: {}, prefix: 'APP_') do
          string :HOST, default: '0.0.0.0'
        end

        expect(result[:HOST]).to eq('0.0.0.0')
      end

      it 'includes prefixed name in error messages' do
        expect do
          described_class.define(env: {}, prefix: 'DB_') do
            string :URL, required: true
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /DB_URL/)
      end

      it 'works with choices validation' do
        env = { 'APP_ENV' => 'production' }

        result = described_class.define(env: env, prefix: 'APP_') do
          string :ENV, required: true, choices: %w[production staging development]
        end

        expect(result[:ENV]).to eq('production')
      end

      it 'raises with prefixed name for invalid choice' do
        env = { 'APP_ENV' => 'invalid' }

        expect do
          described_class.define(env: env, prefix: 'APP_') do
            string :ENV, choices: %w[production staging]
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /APP_ENV must be one of/)
      end

      it 'works without prefix (nil default)' do
        env = { 'HOST' => 'localhost' }

        result = described_class.define(env: env) do
          string :HOST, required: true
        end

        expect(result[:HOST]).to eq('localhost')
      end
    end

    context 'with array type' do
      it 'parses a comma-separated list of strings by default' do
        result = described_class.define(env: { 'TAGS' => 'ruby,rails,hotwire' }) do
          array :TAGS
        end

        expect(result[:TAGS]).to eq(%w[ruby rails hotwire])
      end

      it 'strips whitespace around each element' do
        result = described_class.define(env: { 'TAGS' => 'ruby , rails ,  hotwire  ' }) do
          array :TAGS
        end

        expect(result[:TAGS]).to eq(%w[ruby rails hotwire])
      end

      it 'casts integer elements' do
        result = described_class.define(env: { 'PORTS' => '3000,3001,3002' }) do
          array :PORTS, item_type: :integer
        end

        expect(result[:PORTS]).to eq([3000, 3001, 3002])
      end

      it 'casts float elements' do
        result = described_class.define(env: { 'RATES' => '1.5, 2.0, 3.14' }) do
          array :RATES, item_type: :float
        end

        expect(result[:RATES]).to eq([1.5, 2.0, 3.14])
      end

      it 'casts boolean elements' do
        result = described_class.define(env: { 'FLAGS' => 'true,false,yes,no' }) do
          array :FLAGS, item_type: :boolean
        end

        expect(result[:FLAGS]).to eq([true, false, true, false])
      end

      it 'supports a custom separator' do
        result = described_class.define(env: { 'PATHS' => '/usr/bin:/usr/local/bin:/opt/bin' }) do
          array :PATHS, separator: ':'
        end

        expect(result[:PATHS]).to eq(%w[/usr/bin /usr/local/bin /opt/bin])
      end

      it 'supports a custom separator with integer casting' do
        result = described_class.define(env: { 'IDS' => '1|2|3|4' }) do
          array :IDS, item_type: :integer, separator: '|'
        end

        expect(result[:IDS]).to eq([1, 2, 3, 4])
      end

      it 'yields empty array for empty ENV value' do
        result = described_class.define(env: { 'TAGS' => '' }) do
          array :TAGS
        end

        expect(result[:TAGS]).to eq([])
      end

      it 'yields empty array when ENV var is missing and no default' do
        result = described_class.define(env: {}) do
          array :TAGS
        end

        expect(result[:TAGS]).to eq([])
      end

      it 'uses default when ENV var is missing' do
        result = described_class.define(env: {}) do
          array :TAGS, default: %w[default tag]
        end

        expect(result[:TAGS]).to eq(%w[default tag])
      end

      it 'raises ValidationError when required and missing' do
        expect do
          described_class.define(env: {}) do
            array :TAGS, required: true
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Missing required variable: TAGS/)
      end

      it 'raises CastError for element that cannot cast to integer' do
        expect do
          described_class.define(env: { 'PORTS' => '3000,abc,3002' }) do
            array :PORTS, item_type: :integer
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Cannot cast PORTS/)
      end

      it 'raises CastError for element that cannot cast to boolean' do
        expect do
          described_class.define(env: { 'FLAGS' => 'true,maybe' }) do
            array :FLAGS, item_type: :boolean
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Cannot cast FLAGS/)
      end

      it 'raises CastError for element that cannot cast to float' do
        expect do
          described_class.define(env: { 'RATES' => '1.5,notafloat' }) do
            array :RATES, item_type: :float
          end
        end.to raise_error(Philiprehberger::EnvValidator::ValidationError, /Cannot cast RATES/)
      end

      it 'handles a single-element array' do
        result = described_class.define(env: { 'TAGS' => 'solo' }) do
          array :TAGS
        end

        expect(result[:TAGS]).to eq(['solo'])
      end

      it 'works with prefix option' do
        env = { 'APP_ALLOWED_HOSTS' => 'example.com,api.example.com' }

        result = described_class.define(env: env, prefix: 'APP_') do
          array :ALLOWED_HOSTS
        end

        expect(result[:ALLOWED_HOSTS]).to eq(%w[example.com api.example.com])
      end
    end
  end
end

RSpec.describe Philiprehberger::EnvValidator::Result do
  subject(:result) { described_class.new({ 'PORT' => 3000, 'HOST' => 'localhost' }) }

  describe '#fetch' do
    it 'returns the value' do
      expect(result.fetch(:PORT)).to eq(3000)
    end

    it 'raises KeyError for unknown keys' do
      expect { result.fetch(:UNKNOWN) }.to raise_error(KeyError)
    end
  end

  describe '#[]' do
    it 'is an alias for fetch' do
      expect(result[:HOST]).to eq('localhost')
    end
  end

  describe '#keys' do
    it 'returns all defined variable names' do
      expect(result.keys).to contain_exactly('PORT', 'HOST')
    end
  end

  describe '#key?' do
    it 'returns true for defined variables' do
      expect(result.key?(:PORT)).to be true
    end

    it 'returns false for undefined variables' do
      expect(result.key?(:UNKNOWN)).to be false
    end
  end

  describe '#slice' do
    it 'returns a subset hash of specific keys' do
      expect(result.slice(:PORT)).to eq({ 'PORT' => 3000 })
    end

    it 'returns an empty hash for unknown keys' do
      expect(result.slice(:UNKNOWN)).to eq({})
    end
  end

  describe '#to_h' do
    it 'returns a copy of all values' do
      hash = result.to_h
      expect(hash).to eq({ 'PORT' => 3000, 'HOST' => 'localhost' })
    end

    it 'returns a separate copy each time' do
      hash1 = result.to_h
      hash2 = result.to_h
      expect(hash1).not_to be(hash2)
    end

    context 'with exclude:' do
      subject(:result) do
        described_class.new({ 'PORT' => 3000, 'HOST' => 'localhost', 'API_KEY' => 'secret', 'DB_PASSWORD' => 'pw' })
      end

      it 'filters out keys provided as symbols' do
        expect(result.to_h(exclude: %i[API_KEY DB_PASSWORD])).to eq({ 'PORT' => 3000, 'HOST' => 'localhost' })
      end

      it 'filters out keys provided as strings' do
        expect(result.to_h(exclude: %w[API_KEY DB_PASSWORD])).to eq({ 'PORT' => 3000, 'HOST' => 'localhost' })
      end

      it 'returns full hash when exclude is empty' do
        expect(result.to_h(exclude: [])).to eq({
                                                 'PORT' => 3000,
                                                 'HOST' => 'localhost',
                                                 'API_KEY' => 'secret',
                                                 'DB_PASSWORD' => 'pw'
                                               })
      end

      it 'returns full hash when exclude is omitted' do
        expect(result.to_h).to eq({
                                    'PORT' => 3000,
                                    'HOST' => 'localhost',
                                    'API_KEY' => 'secret',
                                    'DB_PASSWORD' => 'pw'
                                  })
      end

      it 'returns the unchanged hash when excluded keys do not exist' do
        expect(result.to_h(exclude: %i[NOPE MISSING])).to eq({
                                                               'PORT' => 3000,
                                                               'HOST' => 'localhost',
                                                               'API_KEY' => 'secret',
                                                               'DB_PASSWORD' => 'pw'
                                                             })
      end

      it 'does not mutate the original Result' do
        result.to_h(exclude: %i[API_KEY DB_PASSWORD])
        expect(result.to_h).to eq({
                                    'PORT' => 3000,
                                    'HOST' => 'localhost',
                                    'API_KEY' => 'secret',
                                    'DB_PASSWORD' => 'pw'
                                  })
      end
    end
  end

  describe '#freeze!' do
    it 'returns self' do
      result = Philiprehberger::EnvValidator.define(env: { 'API_KEY' => 'abc' }) { string :API_KEY }
      expect(result.freeze!).to be(result)
    end

    it 'freezes the underlying values hash' do
      result = Philiprehberger::EnvValidator.define(env: { 'API_KEY' => 'abc' }) { string :API_KEY }
      result.freeze!
      expect { result.fetch(:API_KEY) << 'x' }.to raise_error(FrozenError)
    end

    it 'freezes string values' do
      result = Philiprehberger::EnvValidator.define(env: { 'NAME' => 'mutable' }) { string :NAME }
      result.freeze!
      expect(result.fetch(:NAME)).to be_frozen
    end

    it 'does not modify already-frozen string values' do
      result = Philiprehberger::EnvValidator.define(env: { 'NAME' => 'preset' }) { string :NAME }
      result.freeze!
      expect { result.fetch(:NAME) }.not_to raise_error
    end
  end

  describe '#slice' do
    it 'returns multiple keys' do
      expect(result.slice(:PORT, :HOST)).to eq({ 'PORT' => 3000, 'HOST' => 'localhost' })
    end
  end

  describe '#[]' do
    it 'raises KeyError for unknown symbol key' do
      expect { result[:NOPE] }.to raise_error(KeyError)
    end
  end
end
