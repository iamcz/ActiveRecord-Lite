require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  class < self

    def columns
      @columns ||= DBConnection
        .columns_for(table_name)
        .map(&:to_sym)
    end

    def table_name
      @table_name ||= self.to_s.underscore.pluralize
    end

    def table_name=(table_name)
      @table_name = table_name
    end

    def finalize!

      columns.each do |name|

        attr_name = ('@' + name.to_s).to_sym
        getter_name = name
        setter_name = (name.to_s + '=').to_sym

        define_method(getter_name) do
          attributes[name]
        end

        define_method(setter_name) do |value|
          attributes[name] = value
        end

      end

    end

  end

  def attributes
    @attributes ||= {}
  end

end
