#
# builtin_string.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class BuiltinStringTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "builtin_string.xml" )
    expected = [
'return ( "a" + "b" )',
'return ( "a" + 42 )',
'return ( "a" + ".path" )',
'return ( "a" + :b )',
'return Ycp::Builtin::tostring( 3.14159 )'
]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
