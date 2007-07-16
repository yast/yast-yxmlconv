#
# void.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class VoidTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "void.xml" ) == "return"
    assert converter_test( "void1.xml" ) == "return nil"
  end
end
