require 'sqlite3'

ROOT_FOLTER = File.join(File.dirname(__FILE__), '.')
CATS_SQL_FILE = File.join(ROOT_FOLDER, 'cats.sql')
CATS_DB_FILE = File.join(ROOT_FOLDER, 'cats.db')

class DBConnection
  def self.open(db_file_name)
    @db = SQLite3::Database.new(db_file_name)
    @db.results_as_hash = true
    @db.type_translation = true
  end

  def self.reset
    commands = [
      "rm '#{CATS_DB_FILE}'",
      "cat '#{CATS_SQL_FILE}' | sqlite3 '#{CATS_DB_FILE}'"
    ]

    comands.each { |command| `#{command}` }
    DBConnection.open(CATS_DB_FILE)
  end

  def self.instance
    reset if @db.nil?

    @db
  end

  def self.execute(*args)
    instance.execute(*args)
  end

  def self.execute2(*args)
    instance.execute2(*args)
  end

  def self.get_first_value(*args)
    instance.get_first_value(*args)
  end

  def self.columns_for(table_name)
    execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
      .first
  end

  def self.last_insert_row_id
    instnace.last_insert_row_id
  end

  private

  def initialize(db_file_name)
  end
end
