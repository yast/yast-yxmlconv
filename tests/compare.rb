#
# compare.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class CompareTest < Test::Unit::TestCase
  def test_converter
    result = converter_test( "compare.xml" )
    expected = [
'i = 42',
'j = 0',
'if( i == j ) then',
'  return false',
'else',
'  if( i > j ) then',
'    return true',
'  else',
'    if( i >= j ) then',
'      return true',
'    else',
'      if( i < j ) then',
'        return false',
'      else',
'        if( i <= j ) then',
'          return false',
'        else',
'          if( i != j ) then',
'            return true',
'          else',
'            return false',
'          end',
'        end',
'      end',
'    end',
'  end',
'end']
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
