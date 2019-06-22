module BlocRecord
  class Collection < Array

    def update_all(updates) # take an array (updates) and set ids using self.map
      ids = self.map(&:id)
      # see if any items in array. if so, retreive first, else return false
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def destroy_all
      self.each { |obj| obj.destroy }
    end
    
  end
end
