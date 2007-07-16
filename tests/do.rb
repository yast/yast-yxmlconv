#
# do.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class DoTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "do.xml" )
    expected = [
'loop do',
'  return false',
'  break unless( false )',
'end' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
