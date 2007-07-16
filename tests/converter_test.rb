#
# ycpxml2ruby/tests/converter_test.rb
#
#  sets output to string and calls XML Listener
#

def converter_test( filename )
  output = ""

  REXML::Document.parse_stream( File.new( "xml/" + filename ), YcpListener.new( output, [ :no_comments ] ) )

  return output

end


