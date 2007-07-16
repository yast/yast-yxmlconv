#
# list.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class ListTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "list.xml" ) == "return [  ]"
    assert converter_test( "list1.xml" ) == "return [ 1 ]"
    assert converter_test( "list2.xml" ) == "return [ 1, 2 ]"
    assert converter_test( "list3.xml" ) == "return [ 1, 2, 3 ]"
    assert converter_test( "listlist.xml" ) == "return [ 1, 2, [ 3, [ 4 ] ] ]"
  end

  def test_nested
    expected = [
'return [ ',
'  { 1 => true }, ',
'  { 2 => false, 3 => :three }, ',
'  {  }, ',
'  { ',
'    1 => 1, ',
'    2 => 2, ',
'    3 => 3, ',
'    4 => 4',
'   }',
' ]'].join "\n"
    assert converter_test( "listmap.xml" ) == expected
  end

end
