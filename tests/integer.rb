#
# integer.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class IntegerTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "integer.xml" ) == "return 42"
  end
end
