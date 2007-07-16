#
# locale.rb
#

require 'test/unit'
require '../src/listener'
require 'converter_test'

class LocaleTest < Test::Unit::TestCase
  def test_locale
    result = converter_test( "locale.xml" )
    expected = [ 
'Ycp::textdomain "en"',
'return _("<p>\'English\'&"Deutsch"</p>")' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
  def test_locale1
    result = converter_test( "locale1.xml" )
    expected = [
'Ycp::textdomain "de"',
'return _("foo", "bar", 42)' ]
    i = 0
    result.split("\n").each{ |l|
      assert l == expected[i]
      i += 1
    }
  end
end
