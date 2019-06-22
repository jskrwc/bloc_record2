module BlocRecord
  class Collection < Array

    def update_all(updates) # take an array (updates) and set ids using self.map
      ids = self.map(&:id)
      # see if any items in array. if so, retreive first, else return false
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take(num=1)   # e.g.   Person.where(first_name: 'John'.take);
      self [0..num-1]
    end

    def where(args)   # e.g.  Person.where(first_name: 'John').where(last_name: 'Smith');
      self.select { |obj| obj.attributes[hash.keys.first] == hash.values.first }
    end

    def not(args)     # e.g.  Person.where.not(first_name: 'John');
      self.select { |obj| obj.attributes[hash.keys.first] != hash.values.first }
    end

  end
end
