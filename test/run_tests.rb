dir_lib = File.dirname(__FILE__) + '/../lib'
$:.unshift dir_lib unless $:.include?(dir_lib)

require 'test/unit'
require 'fileutils'
require 'hum/engine'

class HumText < Test::Unit::TestCase
  
  def setup
    @machine = Hum::Engine.new
    @files = {}
  end

  def test_single
    begin_folder("single")
  end

  def test_simple
    begin_folder("simple")
  end

  def test_nest
    begin_folder("nest")
  end

  def test_comma
    begin_folder("comma")
  end

  def test_line_nest
    begin_folder("line_nest")
  end

  def test_parent_select
    begin_folder("parent_select")
  end

  def test_parent_nest
    begin_folder("parent_nest")
  end

  def test_complex_parent
    begin_folder("complex_parent")
  end

  def test_deep_nest
    begin_folder("deep_nest")
  end

  private
  
  def begin_folder(name)
    @name = name
    @route = make_path(@name)
  
    #loads CSS into the machine
    load_machine
    
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
  
  def make_path(name)
    File.join(File.expand_path('../hum/templates', __FILE__), name)
  end
  
  def load_machine
    @css = File.open("#{@route}/#{@name}.css", 'r')
    @machine.load(@css)
  end
  
  #1
  def compare_sass
    assert_equal(@machine.render_sass, File.open("#{@route}/#{@name}.sass", 'r').read)
  end
  
  #2
  def compare_clean_sass
    assert_equal(@machine.clean_sass, File.open("#{@route}/#{@name}_clean.sass", 'r').read)
  end
  
  #3
  def compare_hashes
    assert_equal(@machine.build_hashes.inspect.to_s, File.open("#{@route}/#{@name}.array", 'r').read)
  end
  
  #4
  def compare_haml_tags
    assert_equal(@machine.render_haml_tags.inspect.to_s, File.open("#{@route}/#{@name}.haml_tags", 'r').read)
  end
  
  #5
  def compare_haml
    assert_equal(@machine.output_haml, File.open("#{@route}/#{@name}.haml", 'r').read)
  end
  
  #6
  def compare_html
    assert_equal(@machine.output_html, File.open("#{@route}/#{@name}_end.html", 'r').read)
  end
  
end