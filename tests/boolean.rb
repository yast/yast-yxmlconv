#
# boolean.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class BooleanTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "boolean.xml" ) == "return true"
  end
end
