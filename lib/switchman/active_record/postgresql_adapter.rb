module Switchman
  module ActiveRecord
    module PostgreSQLAdapter
      include ::ActiveRecord::ConnectionAdapters::PostgreSQL

      def self.included(klass)
        klass::NATIVE_DATABASE_TYPES[:primary_key] = "bigserial primary key".freeze
        klass.send(:remove_method, :quote_table_name) if ::Rails.version < '4' && klass.instance_method(:quote_table_name).owner == klass
      end

      def current_schemas
        select_values("SELECT * FROM unnest(current_schemas(false))")
      end

      def quote_table_name name
        name = Utils.extract_schema_qualified_name(name.to_s)
        if !name.schema && @config[:use_qualified_names]
          name.instance_variable_set(:@schema, shard.name)
        end
        name.quoted
      end
    end
  end
end
