#
# triple.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class TripleTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "triple.xml" ) == "return ( 1 + 1 ) == 2 ? true : false"
  end
end
