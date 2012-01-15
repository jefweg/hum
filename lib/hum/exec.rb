require 'optparse'
require 'fileutils'
require 'hum/engine'
require 'fssm'

module Hum
  
  class Exec
    
    class Generic
      
      def initialize(args)
        @args = args
        
        #Command line options
        @options = {}
        
        #Files to output
        @files = {}
      end
      
      def parse!
        begin
          parse
        rescue Exception => e
          exit 1
        end
        exit 0
      end
      
      def parse
        @opts = OptionParser.new(&method(:set_opts))
        if @args.kind_of? String
          @args = [@args]
        end
        @opts.parse!(@args)
        process_result
      end
      
      protected
      
      def process_result
        args = @args.dup
        input ||=
          begin
            filename = args.shift
            @options[:filename] = filename
          end
        @files[:input] = input
      end
      
    end #Generic
    
    class Hum < Generic

      def initialize(args)
        super
      end
      
      protected
      
      def set_opts(opts)
        opts.on_tail("-v", "--version", "Print version") do
          puts "Hum #{::Hum::VERSION}"
          exit
        end
        opts.on_tail("--watch", "Watch for changes") do
          @options[:watch] = true
        end
      end
      
      def process_result
        return watch if @options[:watch]
        super
        begin
          #open css
          input = @files[:input]
          @machine = Engine.new
          @machine.load(input)          
          @machine.run
        rescue Exception => e
          puts e
        end
      end
      
      private
      
      def watch
        puts ">>> Hum is watching for changes. Press Ctrl-C to stop."
        begin
          current_path = Dir.pwd 
          monitor = FSSM::Monitor.new
          monitor.path current_path, "**/*.css" do
            update do |b, input|
              puts ">>> Change found - #{input}..."
              @machine = Engine.new
              @machine.load(input)
              @machine.run
            end
          end
          monitor.run
        rescue Exception => e
          puts e
        end
      end
      
    end #Hum < Generic
    
  end #Exec
  
end #Hum