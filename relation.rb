class Relation

  def initialize(on_class)
    @on_class = on_class

    @select_statement = on_class.table_name + '.*'
    @from_statement   = on_class.table_name
  end

  def where_values
    @where_values ||= []
  end

  def where(params = {})
    where_values.concat(params.values)
    add_to_where(params.keys)

    self
  end

  private

  def add_to_where(columns)
    if @where_statement.nil?
      @where_statement = where_from(columns)
    else
      @where_statement
        .concat(' AND ')
        .concat(where_from(columns))
    end
  end

  def where_from(columns)
    columns
      .map { |column| column.to_s + ' = ?' }
      .join(' AND ')
  end
end
