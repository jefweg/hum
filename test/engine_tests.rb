dir_lib = File.dirname(__FILE__) + '/../lib'
$:.unshift dir_lib unless $:.include?(dir_lib)

require 'test/unit'
require 'fileutils'
require 'hum/engine'

class HumText < Test::Unit::TestCase
  
  def setup
    @machine = Hum::Engine.new
  end

  #test SASS files
  def test_property_value
    @file = "property_value"
    quick_test
  end

  def test_nests
    @file = "nests"
    quick_test
  end
  
  def test_single_line_nest
    @file = "single_line_nest"
    quick_test
  end
  
  def test_parent_selector
    @file = "parent_selector"
    quick_test
  end
  
  def test_siblings
    @file = "siblings"
    quick_test
  end
  
  def test_insert_extra_child
    @file = "insert_extra_child"
    quick_test
  end
  
  def test_parent_siblings
    @file = "parent_siblings"
    quick_test
  end

  def test_exclude_mixins
    @file = "exclude_mixins"
    quick_test
  end
  
  private

  def quick_test
    #start
    start_engine
    
    #load sass
    load_file
    
    #compare files
    compare_files
  end
  
  def long_test
    #start
    start_engine
    
    #load sass
    load_file

    #runs comparison on the SASS
    compare_sass

    #runs clean sass
    compare_clean_sass

    #parse clean CSS into hashes of data
    compare_hashes

    #compare HAML tags
    compare_haml_tags

    #compare HAML tags
    compare_haml

    #compare HTML
    compare_html
  end
  
  def start_engine
    #path to folders
    @path = File.expand_path('../', __FILE__)
    
    #the starting test
    @sass = File.open("#{@path}/sass/#{@file}.sass", "r")
    
    #the matched result
    @result = File.open("#{@path}/haml/#{@file}.haml", "r")
  end

  def load_file
    @machine.load(@sass)
    @sass.close()
  end
  
  def compare_files
    assert_equal(@machine.run_haml, @result.read)
  end

  def compare_sass
    assert_equal(@machine.render_sass, File.open("#{@path}/long_test/#{@file}.sass", 'r').read)
  end

  def compare_clean_sass
    assert_equal(@machine.clean_sass, File.open("#{@path}/long_test/#{@file}_clean.sass", 'r').read)
  end

  def compare_hashes
    assert_equal(@machine.build_hashes.inspect.to_s, File.open("#{@path}/long_test/#{@file}.array", 'r').read)
  end

  def compare_haml_tags
    assert_equal(@machine.render_haml_tags.inspect.to_s, File.open("#{@path}/long_test/#{@file}.haml_tags", 'r').read)
  end

  def compare_haml
    assert_equal(@machine.output_haml, File.open("#{@path}/long_test/#{@file}.haml", 'r').read)
  end

  def compare_html
    assert_equal(@machine.output_html, File.open("#{@path}/long_test/#{@file}_end.html", 'r').read)
  end
end