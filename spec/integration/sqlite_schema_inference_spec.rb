RSpec.describe 'Schema inference', :sqlite do
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
          name: ROM::SQL::Types::String.meta(name: :name)
        )
      end
    end

    context 'for a table with FKs' do
      let(:dataset) { :tasks }

      it 'can infer attributes for dataset' do
        expect(schema.attributes).to eql(
          id: ROM::SQL::Types::Serial.meta(name: :id),
          title: ROM::SQL::Types::String.optional.meta(name: :title),
          user_id: ROM::SQL::Types::Int.optional.meta(name: :user_id, foreign_key: true, relation: :users)
        )
      end
    end

    context 'for complex table' do
      before do
        conn.drop_table?(:test_inferrence)

        conn.create_table :test_inferrence do
          primary_key :id
          String :text, null: false
          Boolean :flag, null: false
          Date :date
          DateTime :datetime, null: false
          Decimal :money, null: false
          Bytea :data
        end
      end

      let(:dataset) { :test_inferrence }

      it 'can infer attributes for dataset' do
        expected = Hash[
          id: ROM::SQL::Types::Serial.meta(name: :id),
          text: ROM::SQL::Types::String.meta(name: :text),
          flag: ROM::SQL::Types::Bool.meta(name: :flag),
          date: ROM::SQL::Types::Date.optional.meta(name: :date),
          datetime: ROM::SQL::Types::Time.meta(name: :datetime),
          money: ROM::SQL::Types::Decimal.meta(name: :money),
          # data: ROM::SQL::Types::Blob.optional.meta(name: :data)
        ]

        expected.each do |column, definition|
          actual = schema.attributes.fetch(column)
          expect(actual).to eq(definition)
        end
      end
    end
  end
end
