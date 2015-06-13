require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  class < self
    def columns
      @columns ||= DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
        .first
        .map(&:to_sym)
    end

    def table_name
      @table_name ||= self.to_s.underscore.pluralize
    end

    def table_name=(table_name)
      @table_name = table_name
    end
  end
end
