require 'sqlite3'

module Selection

  def find(*ids)
    if ids.length == 1
      find_one(ids.first)
    elsif ids.id_input_error?       # validate the ids - error found?
      raise ArgumentError.new('Ids must be positive integers!')
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one(id)
    if Array(id).id_input_error?
       # private method to check for pos integer input - evaluates arrays
      raise ArgumentError.new('Id must be a positive integer!')
    else
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id = #{id};
      SQL

      init_object_from_row(row)
    end
  end

  def find_by(attribute, value)
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    rows_to_array(rows)
  end

  def method_missing(m, *args, &block)
    # if m == :find_by_name
    #   find_by(:name, +args[0])    # *****
    #    if m.to_s = ~/find_by_(.*)/   # regex to split
    if m.to_s[0..7] == "find_by_"      # split method into 'find_by_' + remainder
      find_by(m.to_s[8..-1] ,+args[0])
    end
  end

  def find_each(opts = {})  # expect start and batch size, block
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{opts[:batch_size]};
    SQL

    for row in rows_to_array(rows)
      yield(row)
    end
  end

  def find_in_batches(opts = {})
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{opts[:batch_size]};
    SQL

    yield(rows_to_array(rows))
  end


  def take(num=1)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
  rows = connection.execute <<-SQL
    SELECT #{columns.join ","} FROM #{table};
  SQL

  rows_to_array(rows)
end


  private

  def init_object_from_row(row)  # converts row into an object
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def rows_to_array(rows)  # gets records, converts the objs into array
    rows.map { |row| new(Hash[columns.zip(row)]) }
  end

  def id_input_error(ids)  # exception if not positive integer
    ids.each do |n|
      if n < 0 || !n.is_a? Integer
        return true   # exception found
      end
    end
    return false
  end


end
