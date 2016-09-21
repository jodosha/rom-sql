require 'rom/types'

module ROM
  module SQL
    module Types
      include ROM::Types

      Serial = ROM::Types::Strict::Int.constrained(gt: 0).meta(primary_key: true)

      String   = ROM::Types::Optional::Coercible::String
      Int      = ROM::Types::Optional::Coercible::Int
      Float    = ROM::Types::Optional::Coercible::Float
      Array    = ROM::Types::Optional::Coercible::Array
      Hash     = ROM::Types::Optional::Coercible::Hash

      Bool     = ROM::Types::Bool.optional
      Decimal  = Types::Decimal.constructor(->(decimal) { ::BigDecimal.new(decimal, ::BigDecimal.double_fig) }).optional
      Date     = ROM::Types::Date.constructor(->(date) { ::Date.parse(date.to_s) }).optional
      Time     = ROM::Types::Time.constructor(->(time) { ::Time.parse(time.to_s) }).optional
      DateTime = ROM::Types::DateTime.constructor(->(datetime) { ::DateTime.parse(datetime.to_s) }).optional

      Blob = Dry::Types::Definition
        .new(Sequel::SQL::Blob)
        .constructor(Sequel::SQL::Blob.method(:new))
    end
  end
end
