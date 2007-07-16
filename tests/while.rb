#
# while.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class WhileTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "while.xml" )
    expected = [
'while( true )',
'  return false',
'end' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
  def test_converter1
    result = converter_test( "while1.xml" )
    expected = [
'while( true )',
'  return false',
'end' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
