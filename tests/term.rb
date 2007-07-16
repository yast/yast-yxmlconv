#
# term.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class TermTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "term.xml" ) == 'return term(  )'
    assert converter_test( "term1.xml" ) == 'return term( 1, false, "true" )'
  end
end
