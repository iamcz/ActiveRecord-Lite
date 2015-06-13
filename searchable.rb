require_relative 'db_connection'
require_relative 'sql_object'
require_relative 'relation'

module Searchable
end

class SQLObject
  extend Searchable
end
