#
# symbol.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class SymbolTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "symbol.xml" ) == "return :symbol"
  end
end
