#
# builtin_boolean.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class BuiltinBooleanTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "builtin_boolean.xml" )
    expected = [
"return ( true && false )",
"return ( false || true )",
"return !( false && false )",
"return !( ( false && ( false || true ) ) || !( true && false ) )" ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
