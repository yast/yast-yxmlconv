#
# bracket_assign.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class BracketAssignTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "bracket_assign.xml" )
    expected = [
'm = {  }',
'm[ 1 ] = 1' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
