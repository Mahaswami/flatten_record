module FlattenRecord
  module Meta
    class ComputeColumn < Column
      def initialize(parent, method, type, target_model, model, options={})
        @column = new_column(method, options[:default], :integer, options[:not_null])  
        super(parent, @column, target_model, model) 
      end

      def denormalize(instance, to_record)
        first_record= to_record.is_a?(Enumerable) ? to_record.first : to_record

        if first_record.respond_to?(@column.name)
          to_record = assign_value(to_record, name) do |record|
            record.send("compute_#{@column.name}".to_sym, instance)
          end
        else
          raise "#{@column.name} is not found in #{to_record.inspect}"
        end
        to_record
      end 

      private
      def new_column(col_name, col_default, col_type, not_null)
        ActiveRecord::ConnectionAdapters::Column.new(col_name, col_default, col_type, not_null)
      end
    end
  end
end
