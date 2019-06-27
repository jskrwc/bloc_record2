module BlocRecord
  # e.g  BlockRecord.connect_to("db/address_bloc.db", :pg)
  # e.g. BlockRecord.connect_to("db/address_bloc.db", :sqlite3)
  def self.connect_to(filename, db_type)   # filename, sqlite or pg
    @database_filename = filename
    @database_type = db_type.to_s
  end

  def self.database_filename
    @database_filename
  end

  def self.database_type
    @database_type
  end

end
