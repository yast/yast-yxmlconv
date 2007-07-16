#
# yebracket.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class YeBracketTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "yebracket.xml" )
    expected = [
'm = { 1 => 1 }',
'return m.bracket( [ 2 ], 0 )' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
