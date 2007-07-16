#
# if.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class IfTest < Test::Unit::TestCase
  def test_if
    result = converter_test( "if.xml" )
    expected = [ 
'if( true ) then',
'  return false',
'end' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
  def test_if1
    result = converter_test( "if1.xml" )
    expected = [
'if( true ) then',
'  return false',
'else',
'  return true',
'end' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
  def test_if2
    result = converter_test( "if2.xml" )
    expected = [
'if( true ) then',
'  return false',
'else',
'  return true',
'end' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
  def test_if3
    result = converter_test( "if3.xml" )
    expected = [
'if( 0 == 1 ) then',
'  return 1',
'else',
'  if( 0 == 2 ) then',
'    return 2',
'  else',
'    if( 0 == 3 ) then',
'      return 3',
'    else',
'      if( 0 == 4 ) then',
'        return 4',
'      else',
'        return 0',
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
