dir_lib = File.dirname(__FILE__) + '/../lib'
$:.unshift dir_lib unless $:.include?(dir_lib)

require 'test/unit'
require 'fileutils'
require 'hum/engine'

class HumText < Test::Unit::TestCase
  
  def setup
    @machine = Hum::Engine.new
  end

  #testing sass-convert
  def test_sass_convert
    #get a bad file
    file = File.open("#{File.expand_path('../', __FILE__)}/other/example.scss", "r")
    
    #load it
    @machine.load(file)
    
    #close it
    file.close()
    
    #should fail
    assert_not_nil(@machine.run_haml)
  end
end