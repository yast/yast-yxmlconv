#
# builtin_float.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class BuiltinFloatTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "builtin_float.xml" )
    expected = [
'return ( 1.42 + 1.42 )',
'return ( 1.42 - 1.42 )',
'return -1.42',
'return ( 1.42 * 1.42 )',
'return ( 1.42 / 1.42 )',
'return Ycp::Builtin::tofloat( "1.42" )' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end

  def test_converter1
    result = converter_test( "builtin_float1.xml" )
    expected = [
"return Ycp::Builtin::tostring( 1.42, 2 )" ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
