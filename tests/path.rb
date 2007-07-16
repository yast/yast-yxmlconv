#
# path.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class PathTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "path.xml" ) == 'return ".a.path"'
  end
end
