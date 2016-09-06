module ROM
  module SQL
    class Schema < ROM::Schema
      require 'rom/sql/schema/column_inferrer'

      class Inferrer
        attr_reader :dsl

        def initialize(dsl)
          @dsl = dsl
        end

        # @api private
        def call(dataset, gateway)
          inferrer = ColumnInferrer.new
          columns  = gateway.connection.schema(dataset)
          fks      = fks_for(gateway, dataset)

          columns.each do |(name, definition)|
            dsl.attribute name, inferrer.infer(name, definition.merge(foreign_key: fks[name]))
          end

          pks = columns
            .map { |(name, definition)| name if definition.fetch(:primary_key) }
            .compact

          dsl.primary_key(*pks) if pks.any?

          dsl.attributes
        end

        private

        # @api private
        def fks_for(gateway, dataset)
          gateway.connection.foreign_key_list(dataset).each_with_object({}) do |definition, fks|
            column, fk = build_fk(definition)

            fks[column] = fk if fk
          end
        end

        # @api private
        def build_fk(columns: , table: , **rest)
          if columns.size == 1
            [columns[0], table]
          else
            # We don't have support for multicolumn foreign keys
            columns[0]
          end
        end
      end
    end
  end
end
