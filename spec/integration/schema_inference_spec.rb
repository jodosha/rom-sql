require 'rom/sql/types/pg'

RSpec.describe 'Schema inference', :postgres do
  include_context 'database setup'

  let(:schema) { container.relations[dataset].schema }

  context 'inferring attributes' do
    before do
      dataset = self.dataset
      conf.relation(dataset) do
        schema(dataset, infer: true)
      end
    end

    context 'for simple table' do
      let(:dataset) { :users }

      it 'can infer attributes for dataset' do
        expect(schema.attributes).to eql(
          id: ROM::SQL::Types::Serial.meta(name: :id),
          name: ROM::SQL::Types::Strict::String.meta(name: :name)
        )
      end
    end

    context 'for a table with FKs' do
      let(:dataset) { :tasks }

      it 'can infer attributes for dataset' do
        expect(schema.attributes).to eql(
          id: ROM::SQL::Types::Serial.meta(name: :id),
          title: ROM::SQL::Types::Strict::String.optional.meta(name: :title),
          user_id: ROM::SQL::Types::Strict::Int.optional.meta(name: :user_id, foreign_key: true, relation: :users)
        )
      end
    end

    with_adapters(:postgres) do
      context 'for complex table' do
        before do
          conn.drop_table?(dataset)

          conn.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"')
          conn.create_table dataset do
            column :id, 'uuid', primary_key: true, default: Sequel.function(:uuid_generate_v4)
            column :uuid1,    'uuid'
            column :price1,   'decimal', null: false
            column :price2,   'decimal'
            column :price3,   'money', null: false
            column :price4,   'money'
            column :file,     'bytea'
            column :date,     'date'
            column :datetime, DateTime,  null: false
            column :flag,     'boolean', null: false
            column :array1,   'integer[]'
            column :array2,   'text[][]'
            column :json1,    'json'
            column :json2,    'jsonb'
          end
        end

        let(:dataset) { :test_inferrence }

        it 'can infer attributes for dataset' do
          expected = Hash[
            id: ROM::SQL::Types::PG::UUID.meta(name: :id, primary_key: true),
            uuid1: ROM::SQL::Types::PG::UUID.optional.meta(name: :uuid1),
            price1: ROM::SQL::Types::Strict::Decimal.meta(name: :price1),
            price2: ROM::SQL::Types::Strict::Decimal.optional.meta(name: :price2),
            price3: ROM::SQL::Types::PG::Money.meta(name: :price3),
            price4: ROM::SQL::Types::PG::Money.optional.meta(name: :price4),
            file: ROM::SQL::Types::Blob.optional.meta(name: :file),
            date: ROM::SQL::Types::Strict::Date.optional.meta(name: :date),
            datetime: ROM::SQL::Types::Strict::Time.meta(name: :datetime),
            flag: ROM::SQL::Types::Strict::Bool.meta(name: :flag),
            array1: ROM::SQL::Types::PG::Array.optional.meta(name: :array1),
            array2: ROM::SQL::Types::PG::Array.optional.meta(name: :array2),
            json1: ROM::SQL::Types::PG::JSON.optional.meta(name: :json1),
            json2: ROM::SQL::Types::PG::JSONB.optional.meta(name: :json2)
          ]

          expected.each do |column, definition|
            actual = schema.attributes.fetch(column)
            expect(actual).to eq(definition)
          end
        end
      end
    end
  end
end
