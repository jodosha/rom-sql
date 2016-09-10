require 'rom/sql/types'
require 'rom/sql/types/pg'

RSpec.describe ROM::SQL::Types, :postgres do
  describe ROM::SQL::Types::Serial do
    it 'accepts ints > 0' do
      expect(ROM::SQL::Types::Serial[1]).to be(1)
    end

    it 'raises when input is <= 0' do
      expect { ROM::SQL::Types::Serial[0] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe ROM::SQL::Types::PG::JSON do
    it 'coerces to pg json hash' do
      input = { foo: 'bar' }

      expect(ROM::SQL::Types::PG::JSON[input]).to eql(Sequel.pg_json(input))
    end

    it 'coerces to pg json array' do
      input = [1, 2, 3]
      output = ROM::SQL::Types::PG::JSON[input]

      expect(output).to be_instance_of(Sequel::Postgres::JSONArray)
      expect(output.to_a).to eql(input)
    end
  end

  describe ROM::SQL::Types::PG::Bytea do
    it 'coerses strings to Sequel::SQL::Blob' do
      input = 'sutin'
      output = described_class[input]

      expect(output).to be_instance_of(Sequel::SQL::Blob)
      expect(output).to eql('sutin')
    end
  end
end
