class Relation
  def initialize(on_class)
    @on_class = on_class

    @select_statement = on_class.table_name + '.*'
    @from_statement   = on_class.table_name
  end
end
