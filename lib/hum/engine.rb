require 'rubygems'
require 'haml'
require 'sass'
require 'sass/css'
require 'hum/string'
require 'hum/array'

module Hum
  #Hum
  class Engine
    #Engine
  
      def initialize
      end
      
      def load(file)
        #the array that holds the parsed CSS
        @tree = []
        
        #the name of the input file
        @input_name = File.basename(file)
        
        #read the input file
        @input_file = File.open(file, 'r')
        
        #the output path
        @output_path = File.absolute_path(file).gsub(/\..*/, ".html")
        
        #the name of the output file
        @output_name = File.basename(@output_path)
        
        #create the output file
        @output_file = File.open(@output_path, "w")
      end
      
      #runs through all the commands
      def run
        #renders SASS from CSS
        render_sass
        
        #remove property value pairs
        clean_sass
        
        #parse CSS into an array of hashes
        build_hashes
        
        #generate HAML tags
        render_haml_tags
        
        #generate HAML
        output_haml
        
        #output the html
        @output_file.write(output_html)
        
        #close the input file
        @input_file.close()
        
        #close the output file
        @output_file.close()

        puts "updated #{@output_name}!\n"
      end
      
      def render_sass
        return _render_sass
      end
      
      def clean_sass
        return _clean_sass
      end
      
      def build_hashes
        return _build_hashes
      end
      
      def render_haml_tags
        return _render_haml_tags
      end
      
      def output_haml
        return _output_haml
      end
      
      def output_html
        return _output_html
      end
      

      private
      
      
      def _render_sass
        
        #if input file is scss, output CSS and convert to SASS
        #if input file is sass, output CSS and continue
        #if input file is CSS, do below
        
        #convert to SASS
        content = @input_file.read
        #remove all comments
        content.gsub!(/\/\*([\s\S]*?)\*\//, "")
        #render sass
        @sass = Sass::CSS.new(content).render(:sass)
      end
      
      def _clean_sass
        #remove all property: value; pairs
        @sass.gsub!((/.*: .*/), "")
        #remove duplicate new lines
        @sass.gsub!((/\n+/), "\n")
      end
      
      def _build_hashes
        i = 1
        #parse into an array of hashes
        @sass.each do |code| 
          hash = { 
            :line =>    i, 
            :select =>  _grab_select(code), 
            :tab =>     _grab_tab(code) 
          }
          @tree << hash
          i += 1
        end
        _check_for_parents
        @tree
      end
      
      def _check_for_parents
        #in each line
        @tree.each do |hash|
          
          #check each selector
          hash[:select].each { |code| 
            
            #if the selector starts with &
            if code.match("&")
              
              #find the parent
              hash[:parent] = @tree.find_parent(hash)[:line]
              
              #find all the kids
              _check_for_kids(hash)
              
            end
          }#end of hash[:select]
          
        end #end of @tree.each
        
        _process_parents_and_kids
     
      end
      
      def _process_parents_and_kids
        
        #look for all parents & kids and modify them
        @tree.each do |hash|
          
          #if the hash has a parent
          if hash[:parent]
            
            #find the parent
            parent = @tree.find_line(hash[:parent])
            
            #if the selector array is only one
            if parent[:select].length == 1
              
              #replace the & with the parent selector
              hash[:select].each do |elm|
                elm.gsub!("&", parent[:select].first)
              end
              
              #update the tab to the parent tab
              hash[:tab] = parent[:tab]
            end
            
            #if this hash has any kids
            if hash[:kids]
              
              #loop through each kid
              hash[:kids].each do |kid|
                
                #find the kid
                child = @tree.find_line(kid)
                
                #and decrease the tab by one
                child[:tab] -= 1
              end
            end
            
          end
        end
        
      end
      
      def _check_for_kids(of_this_hash)
        
        #target the line number
        line_number = of_this_hash[:line] + 1

        #find the line
        found = @tree.find_line(line_number)
        
        #finds the children
        until found.nil? or found[:tab] <= of_this_hash[:tab]
          
          #only create a kids hash if there are kids
          if of_this_hash[:kids].nil?
            of_this_hash[:kids] = []
          end
           
          #add the line to the kids array
          of_this_hash[:kids] << found[:line]
          
          #go up the tree
          line_number += 1

          #find the line
          found = @tree.find_line(line_number)
        end
        
      end
      
      def _grab_select(code)
        result = []
        temp = code.gsub(/\n/, "").gsub(/  /, "")
        if temp.match(", ")
          result = temp.split(", ")
        else
          result.push(temp)
        end
      end
      
      def _grab_tab(code)
        tmp = code[/[ \t]+/]
        if !tmp.nil?
          tmp = tmp.length / 2
        else
          tmp = 0
        end
      end
      
      def _render_haml_tags
        @tree.each do |code|
          code[:haml] = []
          code[:select].each do |tag|
            code[:haml].push(_grab_haml_tag(tag))
          end         
        end
        @tree
      end
      
      def _grab_haml_tag(code)
        #give all classes that start with . or # a DIV element
        if code.match(/^\./) or code.match(/^\#/)
          tag = "%div" + code
        else
          tag = "%" + code
        end
        
        #give all descending tags a %
        if tag.match(" ")
          tag = tag.gsub(" ", " %")
        end
        tag
      end
      
      #Output the HAML
      def _output_haml
        #convert to HAML
        @haml = "%html\n"
        @haml += "\t%head\n"
        @haml += "\t\t%link{:type => 'text/css', :rel => 'stylesheet', :href => '#{@input_name}'}\n"
        #@haml += "\t\t:javascript\n"
        #@haml += "\t\t\tsetTimeout(function(){ parent.location.reload(true); }, 3000)\n"
        @haml += "\t%body\n"
        @tree.each do |hash| 
          
          #empty the kids
          kids = []
          tabs = "\t\t"
          
          #set the base tab
          if hash[:tab] > 0
            tabs += "\t" * hash[:tab]
          end
          
          #if this code was generated from a parent, find the kids
          if !hash[:parent].nil?
            kids = @tree.find_all_kids(hash[:parent], hash[:line])
          end
          
          hash[:haml].each { |haml_tag| 
            
            @haml += _generate_haml_line(tabs, haml_tag, hash)
            
            #if there were kids
            if kids.length != 0
              kids.each { |hash|
              
                #reset the base tab
                tabs = "\t\t"

                #set the base tab
                tabs += "\t" * hash[:tab]
            
                hash[:haml].each do |haml_tag|
                  #generate the HAML
                  @haml += _generate_haml_line(tabs, haml_tag, hash)
                end
                
              }
            end
          }
        end
        @haml
      end
      
      def _generate_haml_line(tabs, element, hash, haml = "")

        #handle a string of descending selectors
        if element.match(" ")

          #so we can give the right indent
          tabs = "\t"
          add_tab = 0

          #collect the descending selectors
          nests = element.split(" ")

          #loop through them and generate the HAML
          nests.each do |nest| 
            
            tabs += "\t"

            #if this is the last descending selector, add content
            if add_tab == nests.length - 1
              haml += tabs + nest + _grab_content(hash) 

            #add a new line
            else
              haml += tabs + nest + "\n"
            end

            add_tab += 1
          end

        #otherwise per normal
        else
          
          #if the hash is from a parent
          if !hash[:parent].nil?
            tabs = "\t\t" + "\t" * @tree.find_line(hash[:parent])[:tab]
          end
          
          haml += tabs + element + _grab_content(hash) 
        end
        
        #returns HAML
        haml
      end
      
      #insert the inner content for HTML tags
      def _grab_content(hash, found = "")
        
        #find the next hash
        next_hash = @tree.find_line(hash[:line] + 1)
        
        #pick the content
        if !next_hash.nil? && next_hash[:tab] > hash[:tab]
          found = "\n"
        else
          found = " Inner content\n"
        end
     
        #if the hash has a parent
        if !hash[:parent].nil?
          
          #find the kids
          kids = @tree.find_all_kids(hash[:parent], hash[:line])
          
          #if there are no kids
          if !kids.empty?
            found = "\n"
          end
          
        end
        
        found
        
      end
      
      def _output_html
        #convert HAML to HAML
        @html = Haml::Engine.new(@haml).render
        @html
      end
  end
  
end