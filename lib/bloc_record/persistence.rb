require 'sqlite3'
require 'bloc_record/schema'

module Persistence

  def self.included(base)
    base.extend(ClassMethods)
  end

  def save
    self.save! rescue false
  end

  def save!
    unless self.id
      self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
      BlocRecord::Utility.reload_obj(self)
      return true
    end

    fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

    self.class.connection.execute <<-SQL
      UPDATE #{self.class.table}
      SET #{fields}
      WHERE id = #{self.id};
    SQL

    true
  end

  def update_attribute(attribute, value)
    # attribute is name of the attribute to which value is assigned
    # pass its own id, and hash of attributes to be updated
    self.class.update(self.id, { attribute => value })
  end

  def update_attributes(updates)
    self.class.update(self.id, updates)
  end


  module ClassMethods
    def create(attrs)
      attrs = BlocRecord::Utility.convert_keys(attrs)
      attrs.delete "id"
      vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }

      connection.execute <<-SQL
        INSERT INTO #{table} (#{attributes.join ","})
        VALUES (#{vals.join ","});
      SQL

      data = Hash[attributes.zip attrs.values]
      data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
      new(data)
    end

    #  #update mulitple records:  e.g.  people = { 1 => { "first_name" => "David" }, 2 => { "first_name" => "Jeremy" } }
    #  Person.update(people.keys, people.values)

    def update(ids, updates)
      case updates
      when Hash
        # convert non-id parameters to array
        updates = BlocRecord::Utility.convert_keys(updates)
        updates.delete "id"
        # use map to convert updates to array of strings (each in format "key=value")
        updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }

        # determine class type of ids, to determine string to append to where_clause
        if ids.class == Fixnum
          where_clause = "WHERE id = #{ids};"
        elsif ids.class == Array
          where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
        else
          where_clause = ";"
        end

        # build out fully formed SQL statement to update the db; then execute it
        connection.execute <<-SQL
          UPDATE #{table}
          SET #{updates_array * ","} #{where_clause}
        SQL

        true

      when Array
        updates.each_with_index { |data, index| update(ids[index], data) }
      end
    end

    def method_missing(m, *args, &block)
      if m == :update_name
        update(self.id, {name: *args[0]})
      end
    end

    def update_all(updates)
      update(nil, updates)
    end
  end
end
