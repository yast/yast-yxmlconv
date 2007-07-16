#
# helper.rb
#

$ycpversion = ""
$debug = false

def debug s
  STDERR.puts "\n** #{s}" if $debug
end

#------------------------------------------------
# Helper class
#

class Helper
  def Helper.attrs2hash attrs
    h = Hash.new
    attrs.each { |a|
      begin
	h[a[0]] = a[1]
      rescue
	raise "Invalid attribute element #{a}"
      end
    }
    h
  end

  def indent level
    level.times "  "
  end

end



