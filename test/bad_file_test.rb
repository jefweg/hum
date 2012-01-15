dir_lib = File.dirname(__FILE__) + '/../lib'
$:.unshift dir_lib unless $:.include?(dir_lib)

require 'test/unit'
require 'fileutils'
require 'hum/engine'

class HumText < Test::Unit::TestCase
  
  def setup
    @machine = Hum::Engine.new
  end

  #testing invalid files
  def test_invalid_file
    #get a bad file
    file = File.open("#{File.expand_path('../', __FILE__)}/other/bad.file", "r")
    
    #load it
    @machine.load(file)
    
    #close it
    file.close()
    
    #should fail
    assert_equal(@machine.run_haml, "")
  end
end