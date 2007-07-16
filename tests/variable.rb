#
# variable.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class VariableTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "variable.xml" ) == "i = 1"
  end
end
