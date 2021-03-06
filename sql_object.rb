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

    def all
      results = DBConnection.execute(<<-SQL)
        SELECT
          #{table_name}.*
        FROM
          #{table_name}
      SQL

      parse_all(results)
    end

    def parse_all(results)
      results.map { |result| self.new(result) }
    end

    def find(id)
      results = DBConnection.execute(<<-SQL, id)
        SELECT
          *
        FROM
          #{table_name}
        WHERE
          id = ?
      SQL

      results.emtpy? ? nil : self.new(results.first)
    end

  end

  def initialize(params = {})
    params.each do |name, value|
      unless self.class.columns.include?(name.to_sym)
        raise "unknown attribute '#{name}'"
      end

      setter_name = (name.to_s + '=').to_sym
      self.send(setter_name, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    values_statement = attribute_values
      .map { |attr_value| '?' }
      .join(', ')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{self.class.columns.join(', ')})
      VALUES
        (#{values_statement})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_statement = self
      .class
      .columns
      .map { |name| name.to_s + ' = ?' }
      .join(', ')

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_statement}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end

end
