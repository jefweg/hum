class Array
  #find a specific line
  def find_line(target, found = nil)
    self.each do |css| 
      if css[:line] == target
        found = css
      end
    end
    found
  end
  
  #find the parent of a line
  def find_parent(of_this_hash, found = nil)
    
    #target the line number
    line_number = of_this_hash[:line] - 1
    
    #find the line
    found = self.find_line(line_number)

    #finds the direct parent with the correct tab
    until found.nil? or found[:tab] == of_this_hash[:tab] - 1
      
      #go up the tree
      line_number -= 1
      
      #find the line
      found = self.find_line(line_number)
    end

    #return the right parent line
    found[:line]
  end
  
  def find_kids(hash, kids = [])
    
    #get the next line number
    next_line = hash[:line] + 1
    
    #find the next one
    found = self.find_line(next_line)
    
    until found.nil? or hash[:tab] >= found[:tab]
      
      #collect it if not a mixin
      if !found[:exclude]
        kids << found[:line]
      end
      
      #increment
      next_line += 1
      
      #find the next one
      found = self.find_line(next_line)
    end
    
    #return all kids
    kids
  end
  
  def find_extra_kids(hash, kids = [])
    
    #find the parent
    parent = self.find_line(hash[:parent])
    
    #target the next line
    next_line = hash[:parent] + 1

    #find the next line
    found = self.find_line(next_line)
    
    until found.nil? or next_line == hash[:line] or parent[:tab] == found[:tab]
      
      #collect it if not a mixin
      if !found[:exclude]
        kids << found[:line]
      end
    
      #increment
      next_line += 1
      
      #find the next one
      found = self.find_line(next_line)
    end
    
    kids
  end
end