#
# map.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class MapTest < Test::Unit::TestCase
  def test_converter
    assert converter_test( "map.xml" ) == 'return {  }'
    assert converter_test( "map1.xml" ) == 'return { 1 => "one" }'
    assert converter_test( "map2.xml" ) == 'return { 1 => "one", 2 => "two" }'
    assert converter_test( "map3.xml" ) == 'return { 1 => "one", "three" => 3, :zwei => "two" }'
    assert converter_test( "mapmap.xml" ) == 'return { 1 => { :eins => "one" }, 2 => {  } }'
  end

  def test_nested
    expected = [
'return { ',
'  1 => [ {  } ], ',
'  2 => [ :two, { 3 => "three" } ], ',
'  3 => [ :three, { 4 => "four" }, { 5 => "fize" } ], ',
'  4 => [ ',
'    :four, ',
'    { 5 => "five" }, ',
'    { 6 => "six" }, ',
'    { 7 => "seven" }',
'   ]',
' }'].join( "\n" )
    assert converter_test( "maplist.xml" ) == expected
  end

#  def test_yemap
#    assert converter_test( "map4.xml" ) == 'Ycp::textdomain "en"\ncmdline = {"id" => "language", "help" => _("Language configuration"), "guihandler" => nil, "initialize" => nil, "finish" => nil, "actions" => {"summary" => {"handler" => nil, "help" => _("Language configuration summary")}, "set" => {"handler" => nil, "help" => _("Set new values for language")}, "list" => {"handler" => nil, "help" => _("List all available languages.")}}, "options" => {"lang" => {"help" => _("New language value"), "type" => "string"}, "languages" => {"help" => _("List of secondary languages (separated by commas)"), "type" => "string"}}, "mappings" => {"list" => [], "set" => ["lang", "languages"], "summary" => []}}'
#  end
end
