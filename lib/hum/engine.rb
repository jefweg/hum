require 'rubygems'
require 'haml'
require 'sass'
require 'sass/exec'
require 'sass/css'
require 'hum/string'
require 'hum/array'
require 'colored'
require 'optparse'
require 'fileutils'

module Hum
  #Hum
  class Engine
    #Engine
  
      def initialize
      end
      
      def load(file)
        #the array that holds the parsed CSS
        @tree = []
        
        @input_path = file
        
        #the name of the input file
        @input_name = File.basename(file)
        
        #read the input file
        @input_file = File.open(file, 'r')
        
        @directory = File.dirname(file)
        
        #the output path
        @output_path = File.expand_path(file).gsub(/\..*/, ".html")
        
        #the name of the output file
        @output_name = File.basename(@output_path)
      end
      
      def run
        run_haml
        
        #create the output file
        @output_file = File.open(@output_path, "w")
        
        #output the html
        @output_file.write(output_html)
        
        #close the input file
        @input_file.close()
        
        #close the output file
        @output_file.close()
        
        puts "updated #{@output_name}".bold
      end
      
      def run_haml
        #render SASS from CSS
        render_sass
        
        #remove property value pairs
        clean_sass
        
        #parse CSS into an array of hashes
        build_hashes
        
        #generate HAML tags
        render_haml_tags
        
        #generate HAML
        output_haml
      end
      
      def render_sass
        #read content
        content = @input_file.read

        #remove all comments
        content.gsub!(/\/\*([\s\S]*?)\*\//, "")

        #if CSS render SASS
        if @input_name.match(/\.css/)
          @sass = Sass::CSS.new(content).render(:sass)

        #if SCSS convert to SASS
        elsif @input_name.match(/\.scss/)
          @sass = ::Sass::Engine.new(content, { :cache => false, :read_cache => true, :syntax => :scss }).to_tree.send("to_sass")

        #if sass keep as it
        elsif @input_name.match(/\.sass/)
          @sass = content

        #if nothing then put error
        else
          puts "Hum only works with .scss, .sass and .css files.".bold
          exit 1
        end
      end
      
      def clean_sass
        #remove all property: value; pairs
        @sass.gsub!(/.*: .*/, "")
        
        #make sure tabs are two spaces
        @sass.gsub!(/\t/, "  ")
        
        #make sure nested direct descendant is normal
        @sass.gsub!(/\& > /, "")
        
        #make sure direct descendant is normal
        @sass.gsub!(/ > /, " ")
        
        #remove duplicate new lines
        @sass.gsub!(/\n+/, "\n")
      end
      
      def build_hashes
        
        i = 1
        
        #parse into an array of hashes
        @sass.each do |code| 
          hash = { 
            :line =>    i, 
            :select =>  _grab_select(code), 
            :tab =>     _grab_tab(code),
            :parent =>   nil,
            :kids =>    []
          }
          @tree << hash
          i += 1
        end
        
        #mark all parent selectors
        _check_for_parents
        
        #collect all kids
        _collect_kids
        
        #process all tags of parent selectors
        _process_parents
        
        #process all tabs
        _process_tabs
        
        #process all mixins by fixing the tabs and removing the mixin
        _process_mixins

        #process all special selectors, like pseudo elements
        _process_special
        
        @tree
      end
      
      def render_haml_tags
        #in each line
        @tree.each do |hash|
          hash[:haml] = []
          
          #for each selector
          hash[:select].each do |tag|
            
            #convert the tag to a HAML tag
            hash[:haml].push(_grab_haml_tag(tag))
          end         
        end
        @tree
      end
      
      def output_haml
        return _output_haml
      end
      
      def output_html
        #convert HAML to HAML
        @html = Haml::Engine.new(@haml).render
        @html
      end

      private
      
      def _check_for_parents
        #in each line
        @tree.each do |hash|
          
          #check each selector
          hash[:select].each { |code| 
            
            #if the selector starts with &
            if code.match("&")
              
              #find the parent
              hash[:parent] = @tree.find_parent(hash)
              
            end
          }
        end
      end
      
      def _collect_kids
        #in each line
        @tree.each do |hash|
          
          #if hash has a parent
          if !hash[:parent].nil?
            
            #find all the kids
            hash[:kids] = @tree.find_kids(hash)
          end
          
        end
      end

      def _process_parents
        #in each line
        @tree.each { |hash|
          
          #if the hash has a parent          
          if !hash[:parent].nil?
            
            #find it
            parent = @tree.find_line(hash[:parent])
            
            if parent[:select].length == 1
              
              #and replace the &
              hash[:select].each { |elm|
                elm.gsub!("&", parent[:select].first)
              }
              
            end
            
          end 
        }
      end

      def _process_tabs
        #in each line
        @tree.each { |hash|
          
          #if there is a parent
          if !hash[:parent].nil?
            
            #reduce tab by 1
            hash[:tab] -= 1
            
            #if there are kids
            if !hash[:kids].empty?
              
              #for each kid
              hash[:kids].each { |kid|
                
                #find it
                child = @tree.find_line(kid)
                
                #and reduce it by one
                child[:tab] -= 1
                
              }
            end
          end
        }
      end
      
      def _process_mixins
        #in each line
        @tree.each { |hash|
          
          #for each select
          hash[:select].each do |code|
            
            #if this is a mixin
            if code.match(/\+/)
              hash[:exclude] = true
              
            #if this is a named mixin
            elsif code.match(/\=/)
              
              #ignore the hash on output
              hash[:exclude] = true
              
              #find kids
              kids = @tree.find_kids(hash)

              #for each kid
              kids.each { |kid|
                
                #find it
                child = @tree.find_line(kid)
                
                #and reduce it by one
                child[:tab] -= 1
              }
            end
          end
        }
      end
      
      def _process_special
        #in each line
        @tree.each { |hash|
          
          #for each select
          hash[:select].each do |code|
            
            #if this has a pseudo element
            if code.match(/:/)
              
              #remove it
              code.gsub!(/:.*/, "")
            end
            
          end
        }
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
      
      def _grab_haml_tag(code)
        #give all classes that start with . or # a DIV element
        if code.match(/^\./) or code.match(/^\#/)
          tag = "%div" + code
        else
          tag = "%" + code
        end
        
        #give all descending tags a %, there's probably a better way to do this
        if tag.match(" ")
          tag = tag.gsub(" ", " %")
        end
        
        if tag.match("%.")
          tag = tag.gsub("%.", "%div.")
        end
        
        if tag.match("%#")
          tag = tag.gsub("%#", "%div#")
        end
        
        #give all links an href
        if tag.match("%a")
          tag = tag.gsub("%a", "%a{:href=>'#'}")
        end
        
        tag
      end
      
      #Output the HAML
      def _output_haml
        
        #convert to HAML
        @haml = "%html\n"
        @haml += "\t%head\n"
        @haml += "\t\t%link{:type => 'text/css', :rel => 'stylesheet', :href => '#{@input_name.gsub(/\..*/, ".css")}'}\n"
        @haml += "\t%body\n"
        
        #time to build the HAML
        @tree.each do |hash|
          
          if hash[:exclude] != true
            
            extra = []
          
            #if there's a parent, find the extra kids
            if !hash[:parent].nil?
              extra = @tree.find_extra_kids(hash)
            end
          
            #for each generate the HAML line
            hash[:haml].each { |haml_tag| 
            
              #if no extra, just normal
              if extra.empty?  
                @haml += _generate_haml_line(haml_tag, hash)
            
              #else extra
              else  
              
                #this hash has extra kids
                hash[:extra] = true
              
                @haml += _generate_haml_line(haml_tag, hash)
              
                #for each kid
                extra.each { |line|
                
                  #get the hash
                  extra_hash = @tree.find_line(line)
                
                  #for each generate the HAML line
                  extra_hash[:haml].each do |haml_tag|
                  
                    #do it
                    @haml += _generate_haml_line(haml_tag, extra_hash)
                  end
                }
              end

            }
        
          end
        end
        @haml
      end
      
      def _generate_haml_line(element, hash, haml = "")

        #handle a string of descending selectors
        if element.match(" ")
          
          tabs = "\t\t" + "\t" * hash[:tab]
          count = 0

          #collect all tags
          nests = element.split(" ")

          #for each tag
          nests.each do |nest| 
            
            if count != 0
              tabs += "\t"
            end

            #if this is the last one, check for content
            if count == nests.length - 1
              haml += tabs + nest + _grab_content(hash) 

            #else add a new line
            else
              haml += tabs + nest + "\n"
            end

            count += 1
          end

        #otherwise per normal
        else
          
          #make tabs
          tabs = "\t\t" + "\t" * hash[:tab]
          
          #make HAML
          haml += tabs + element + _grab_content(hash) 
        end

        haml
      end
      
      #insert the inner content for HTML tags
      def _grab_content(hash, found = "")
        
        #find the next hash
        next_hash = @tree.find_line(hash[:line] + 1)
        
        #if it has kids, add a new line
        if !next_hash.nil? and next_hash[:tab] > hash[:tab]
          found = "\n"
        
        #else put in content
        else
          found = " Inner content\n"
        end
        
        #if kids, it's a new line
        if hash[:kids].length > 0 or hash[:extra] == true
          found = "\n"          
        end
        
        found
      end
      
  end
  
end