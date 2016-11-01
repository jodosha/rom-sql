require 'dry-types'
require 'sequel'

module ROM
  module SQL
    module Types
      module PG
        # UUID

        UUID = Types::String

        # Array

        Sequel.extension(:pg_array)
        Sequel.extension(:pg_array_ops)

        Array = Dry::Types::Definition
                .new(Sequel::Postgres::PGArray)

        def self.Array(db_type)
          Array.constructor(-> (v) { Sequel.pg_array(v, db_type) }).meta(type: db_type)
        end

        # JSON

        Sequel.extension(:pg_json)
        Sequel.extension(:pg_json_ops)

        JSONArray = Dry::Types::Definition
                    .new(Sequel::Postgres::JSONArray)
                    .constructor(Sequel.method(:pg_json))

        JSONHash = Dry::Types::Definition
                   .new(Sequel::Postgres::JSONHash)
                   .constructor(Sequel.method(:pg_json))

        JSONOp = Dry::Types::Definition
                 .new(Sequel::Postgres::JSONOp)
                 .constructor(Sequel.method(:pg_json))

        JSON = JSONArray | JSONHash | JSONOp

        # JSONB

        JSONBArray = Dry::Types::Definition
                     .new(Sequel::Postgres::JSONBArray)
                     .constructor(Sequel.method(:pg_jsonb))

        JSONBHash = Dry::Types::Definition
                    .new(Sequel::Postgres::JSONBHash)
                    .constructor(Sequel.method(:pg_jsonb))

        JSONBOp = Dry::Types::Definition
                  .new(Sequel::Postgres::JSONBOp)
                  .constructor(Sequel.method(:pg_jsonb))

        JSONB = JSONBArray | JSONBHash | JSONBOp

        Bytea = Dry::Types::Definition
                .new(Sequel::SQL::Blob)
                .constructor(Sequel::SQL::Blob.method(:new))

        # MONEY

        Money = Types::Decimal
      end
    end
  end
end
