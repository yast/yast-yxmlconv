#
# float.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class FloatTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "float.xml" ) == "return 42.42"
  end
end
