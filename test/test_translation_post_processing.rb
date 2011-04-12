#!/usr/local/bin/ruby -w

$TESTING = true

# this is a test stub for now
# lets review these
# neee to remove this constant from tests and pull it from rad
C_VAR_TYPES = "unsigned|int|long|double|str|char|byte|float|bool"
require "rubygems"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/rad/rad_processor.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/rad/rad_rewriter.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/rad/rad_type_checker.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/rad/variable_processing"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/rad/arduino_sketch"
require 'test/unit'

class TestTranslationPostProcessing < Test::Unit::TestCase
  def setup
    $external_var_identifiers = ["__foo", "__toggle", "wiggle"]   
    $define_types = { "KOOL" => "long", "ZAK" => "str"}
    $array_types = { "my_array" => "int"}
    
    
  end
  
  # remove these external variables and parens on variables
  # need to actually run code through ruby_to_c for some of these tests
  
  def test_int
    name = "foo_a"
    value_string = "int(__toggle = 0);"
    expected = ""
    result = ArduinoSketch.post_process_ruby_to_c_methods(value_string)
    assert_equal(expected, result)
  end
  
  def test_bool
    name = "foo_b"
    value_string = "bool(__toggle = 0);"
    expected = ""
    result = ArduinoSketch.post_process_ruby_to_c_methods(value_string)
    assert_equal(expected, result)
  end
  
  def test_long
    name = "foo_c"
    value_string = "long(__foo = 0);"
    expected = ""
    result = ArduinoSketch.post_process_ruby_to_c_methods(value_string)
    assert_equal(expected, result)
  end
  
  def test_trans_one
    name = "foo_d"
    expected = "void\none() {\ndelay(1);\n}"    
    result = raw_rtc_meth = util_translate(:one)
    assert_equal(expected, result)
  end
  
  # notice the nice behavior of @foo
  def test_trans_two
    name = "foo_e"
    expected = "void\ntwo() {\ndelay(1);\n__foo = 1;\n}"    
    result = raw_rtc_meth = util_translate(:two)
    assert_equal(expected, result)
  end
  
  # notice the nice behavior of @foo
  def test_trans_three
    name = "foo_f"
    expected = "void\nthree() {\nlong bar;\nvoid * baz;\n__foo = 1;\nbar = 2;\nbaz = wha();\n}"    
    result = raw_rtc_meth = util_translate(:three)
    assert_equal(expected, result)
  end
  
  # need to take a closer look at this ... include "void * wiggle" regex?
  # 
  def test_trans_four
    name = "foo_f"
    expected = "void\nfour() {\nlong bar;\nvoid * wiggle;\n__foo = 1;\nbar = 2;\nwiggle = wha();\n}"    
    result = raw_rtc_meth = util_translate(:four)
    assert_equal(expected, result)
  end
  
  def test_trans_five
    name = "foo_f"
    expected = "void\nfive() {\nlong f;\n__foo = 1;\nf = KOOL;\n}"
    result = raw_rtc_meth = util_translate(:five)
    assert_equal(expected, result)
  end
  
  def test_trans_six
    name = "foo_f"
    expected = "void\nsix() {\nstr a;\na = ZAK;\n}"
    result = raw_rtc_meth = util_translate(:six)
    assert_equal(expected, result)
  end
  
  def test_trans_seven
    name = "foo_f"
    expected = "void\nseven(long int) {\nlong a;\na = int * 2;\n}"
    result = raw_rtc_meth = util_translate(:seven)
    assert_equal(expected, result)
  end
  
  def test_trans_eight
    name = "foo_f"
    expected = "void\neight(long str) {\nvoid * a;\na = ZAK + str;\n}"
    result = raw_rtc_meth = util_translate(:eight)
    assert_equal(expected, result)
  end
  
  def test_trans_nine
    name = "foo_f"
    expected = "void\nnine() {\nunsigned int index_a;\nfor (index_a = 0; index_a < (int) (sizeof(__my_array) / sizeof(__my_array[0])); index_a++) {\nint a = __my_array[index_a];\ndelay(a);\n}\n}"
    result = raw_rtc_meth = util_translate(:nine)
    assert_equal(expected, result)
  end

  def util_translate meth
    RadProcessor.translate("test/fixture.rb", :TranslationTesting, meth)
  end
  
  ## need to look at unsigned long 
  ## need parens removal tests
  


end
