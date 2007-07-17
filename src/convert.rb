#
# ycp xml to ruby converter
#

$LOAD_PATH << File.dirname(__FILE__) # find all other files in same dir

require 'listener'

argc = ARGV.length
check = false
output = STDOUT

if (argc == 0) then
  input = STDIN
else
  argp = 0
  if (ARGV[argp] == "--debug") then
    argp += 1
    $debug = true
  end
  if (ARGV[argp] == "--check") then
    argp += 1
    check = true
    output = File.new( "/dev/null", "w+" )
  end
  input = File.new( ARGV[argp] )
  STDERR.puts "Checking #{ARGV[argp]}" if check
end

REXML::Document.parse_stream( input, YcpListener.new( output ) )
puts ""
