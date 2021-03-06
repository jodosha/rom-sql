module ROM
  module SQL
    # @private
    class Header
      include Dry::Equalizer(:columns, :table)

      SEP_REGEX = /_{2,3}/.freeze

      attr_reader :columns, :table

      def initialize(columns, table)
        @columns = columns
        @table = table
      end

      def to_ary
        columns
      end
      alias_method :to_a, :to_ary

      def to_h
        columns.each_with_object({}) do |col, h|
          left, right = col.to_s.split('___')
          h[left.to_sym] = (right || left).to_sym
        end
      end

      def names
        columns.map { |col| :"#{col.to_s.split(SEP_REGEX).last}" }
      end

      def exclude(*names)
        self.class.new(columns.find_all { |col| !names.include?(col) }, table)
      end

      def project(*names)
        self.class.new(columns.find_all { |col| names.include?(col) }, table)
      end

      def qualified
        self.class.new(columns.map { |col| :"#{table}__#{col}" }, table)
      end

      def rename(options)
        self.class.new(columns.map { |col|
          new_name = options[col]

          if new_name
            :"#{col}___#{new_name}"
          else
            col
          end
        }, table)
      end

      def prefix(col_prefix)
        rename(Hash[columns.map { |col| [col, :"#{col_prefix}_#{col}"] }])
      end
    end
  end
end
