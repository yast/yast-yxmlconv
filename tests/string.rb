#
# string.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class StringTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "string.xml" ) == 'return "string"'
  end
end
