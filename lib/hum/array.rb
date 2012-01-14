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

    #return the right parent
    found
  end
  
  #find the children from a line to a hash
  def find_all_kids(line, to_line, kids = [])
      
    #find the parent
    parent = self.find_line(line)
    
    #target the line number
    line_number = line + 1
    
    #find the first found
    found = self.find_line(line_number)
    
    until found.nil? or line_number == to_line or parent[:tab] == found[:tab]
      #add the line to the array
      kids << found
      
      #increment the line number
      line_number += 1
      
      #find the new found
      found = self.find_line(line_number)
    end
    
    #return the kids
    kids
  end
end