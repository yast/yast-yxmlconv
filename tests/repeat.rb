#
# repeat.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class RepeatTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "repeat.xml" )
    expected = [
'repeat begin',
'  return false',
'end',
'until( false )' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
