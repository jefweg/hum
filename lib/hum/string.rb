#Fixes string.each in ruby 1.9
unless "".respond_to?(:each)
  String.class_eval do
    def each &block
      self.lines &block
    end	
  end
end