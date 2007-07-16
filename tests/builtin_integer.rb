#
# builtin_integer.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class BuiltinIntegerTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "builtin_integer.xml" )
    expected = [
'return ( 1 + 1 )',
'return ( 1 - 1 )',
'return -42',
'return ( 1 * 1 )',
'return ( 1 / 1 )',
'return ( 1 % 1 )',
'return ( 1 & 1 )',
'return ( 1 ^ 1 )',
'return ( 1 | 1 )',
'return ( 1 << 1 )',
'return ( 1 >> 1 )',
'return ~1',
'return Ycp::Builtin::tointeger( "1" )' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
