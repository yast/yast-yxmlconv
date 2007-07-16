#
# Expression
#

require 'helper'

#------------------------------------------------
# Parse <const .../>
#

class YConstant
  def tag_start( name, attrs )
    h = Helper.attrs2hash attrs
    debug "#{self}.tag_start(#{name}, #{h})"
    case h["type"]
      when "void"
	$output.o( "nil" )
      when "string", "path"
	$output.o( '"' << h["value"] << '"' )
      when "symbol"
	$output.o( ':' << h["value"] )
      else
	$output.o( h["value"] )
    end
  end
  def tag_end( name )
    debug "YConstant.tag_end(#{name})"
    return false if name == "const"
    raise "#{self}.tag_end(#{name}) UNKNOWN"
  end
end

#------------------------------------------------
# Parse <list>...</list>
#

class YList
  def initialize
    @count = 0
    @pending = nil
    @listener = nil
    @size = 0
  end

  def tag_start( name, attrs )
    return @listener.tag_start( name, attrs ) if @listener
    debug "#{self}.tag_start(#{name}) @listener #{@listener}"
    if (@pending == :expression) then
      if (@count > 0)
	$output.o( :sep ) 
	$output.o( [:eol] ) if @size > 3
      end
      @listener = YExpression.new
      @pending = nil
      return @listener.tag_start( name, attrs )
    end
    case name
      when "element"
	@pending = :expression
      when "list"
	h = Helper.attrs2hash attrs
	@size = h["size"].to_i if h["size"]
	$output.o( "[ " )
	$output.o( [:eol, :inc] ) if @size > 3
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end
  def tag_end( name )
    debug "#{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @count += 1
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "list"
	$output.o( [:eol, :dec] ) if @size > 3
	$output.o( " ]" )
	return false
      when "element"
	@pending = nil
	return true
    end
    raise "#{self}.tag_end(#{name}) UNKNOWN" unless @listener
    return true
  end
end


#------------------------------------------------
# Parse <map>...</map>
#

class YMap
  def initialize
    @count = 0
    @pending = nil
    @listener = nil
    @have_key = false
    @size = 0
  end

  def tag_start( name, attrs )
    return @listener.tag_start( name, attrs ) if @listener
    debug "#{self}.tag_start(#{name}) @pending #{@pending} @have_key #{@have_key}"
    case @pending
      when :kexpression, :vexpression
	if ( (@count > 0) && (@pending == :kexpression)) then
	  $output.o( :sep )
	  $output.o( :eol ) if @size > 3
	end
	@listener = YExpression.new
	@pending = :key if @pending == :kexpression
	@pending = :value if @pending == :vexpression
	debug "#{self}.tag_start(#{name}) @pending #{@pending} -> @listener #{@listener}"
	return @listener.tag_start( name, attrs )
      when :key
	@pending = :kexpression
      when :value
	@pending = :vexpression
      else begin
	case name
	  when "map"
	    h = Helper.attrs2hash attrs
	    @size = h["size"].to_i if h["size"]
	    $output.o( "{ " )
	    $output.o( [:eol, :inc] ) if @size > 3
	  when "element"
	    raise "Value missing" if @have_key
	    @pending = :key
	  when "key"
	    raise "Duplicate key" if @have_key
	    @pending = :value
	  when "value"
	    raise "Value without key" unless @have_key
	    $output.o( " => " )
	    @pending = :vexpression
	  else
	    raise "#{self}.tag_start(#{name}) UNKNOWN"
	end
      end
    end
    return true
  end
  def tag_end( name )
    debug "#{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "map"
	$output.o( [:eol, :dec] ) if @size > 3
	$output.o( " }" )
	return false
      when "key"
	@pending = nil
	@have_key = true
      when "value"
	@count += 1
	@pending = nil
	@have_key = false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN" if @listener
    end
    return true		# wait for </map>
  end
end

#------------------------------------------------
# Parse <yeunary ...
#

class YEUnary
  def initialize
    @pending = nil
    @listener = nil
  end

  def tag_start( name, attrs )
    return @listener.tag_start( name, attrs ) if @listener
    debug "#{self}.tag_start(#{name}) @listener #{@listener}"
    if (@pending == :expression) then
      @listener = YExpression.new
      @pending = nil
      return @listener.tag_start( name, attrs )
    end
    case name
      when "yeunary"
	h = Helper.attrs2hash attrs
	@pending = :expression
	$output.o( h["name"] )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
  def tag_end( name )
    debug "#{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      @pending = nil
      return true
    end
    case name
      when "yeunary"
	return false
    end
    raise "#{self}.tag_end(#{name}) UNKNOWN" unless @listener
    return true
  end
end


#------------------------------------------------
# Parse <yebinary ...
#

class YEBinary
  def initialize
    @count = 0
    @pending = nil
    @listener = nil
    @name = nil
  end

  def tag_start( name, attrs )
    return @listener.tag_start( name, attrs ) if @listener
    debug "#{self}.tag_start(#{name}) @listener #{@listener}"
    if (@pending == :expression) then
      $output.o( { :op => @name } ) if (@count > 0)
      raise "More than two expressions within <yebinary>" if @count > 2
      @listener = YExpression.new
      @pending = nil
      return @listener.tag_start( name, attrs )
    end
    case name
      when "yebinary"
	h = Helper.attrs2hash attrs
	@name = h["name"]
	@pending = :expression
	$output.o( :po )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
  def tag_end( name )
    debug "#{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      @pending = :expression
      @count += 1 unless @listener
      return true
    end
    case name
      when "yebinary"
	$output.o( :pc )
	return false
    end
    raise "#{self}.tag_end(#{name}) UNKNOWN" unless @listener
    return true
  end
end


#------------------------------------------------
# Parse <call> ... <args> ...
#

class YCall
  def initialize
    @count = 0
    @pending = nil
    @listener = nil
  end

  def tag_start( name, attrs )
    return @listener.tag_start( name, attrs ) if @listener
    debug "#{self}.tag_start(#{name}) @listener #{@listener}"
    if (@pending == :expression) then
      $output.o( :sep ) if (@count > 0)
      @listener = YExpression.new
      @pending = nil
      return @listener.tag_start( name, attrs )
    end
    case name
      when "args"
	@pending = :expression
      when "call"
	h = Helper.attrs2hash attrs
	if h["ns"] && (!h["ns"].empty?) then
	  $output.o( :ycp => h["ns"] )
	  $output.o( :str => "::" )
	end
	$output.o( h["name"] )
	$output.o( :po )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "#{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @count += 1
      @listener = nil unless @listener.tag_end( name )
      @pending = :expression
      return true
    end
    case name
      when "call"
	$output.o( :pc )
	return false
      when "args"
	@pending = nil
	return true
    end
    raise "#{self}.tag_end(#{name}) UNKNOWN" unless @listener
    return true
  end
end


#------------------------------------------------
# Parse <yeterm> ... <element> ... </yeterm>
#

class YETerm
  def initialize
    @count = 0
    @pending = nil
    @listener = nil
  end

  def tag_start( name, attrs )
    return @listener.tag_start( name, attrs ) if @listener
    debug "#{self}.tag_start(#{name}) @listener #{@listener}"
    if (@pending == :expression) then
      $output.o( :sep ) if (@count > 0)
      @listener = YExpression.new
      @pending = nil
      return @listener.tag_start( name, attrs )
    end
    case name
      when "element"
	@pending = :expression
      when "yeterm"
	h = Helper.attrs2hash attrs
	$output.o( h["name"] )
	$output.o( :po )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "#{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @count += 1
      @listener = nil unless @listener.tag_end( name )
      @pending = :expression
      return true
    end
    case name
      when "yeterm"
	$output.o( :pc )
	return false
      when "element"
	@pending = nil
	return true
    end
    raise "#{self}.tag_end(#{name}) UNKNOWN" unless @listener
    return true
  end
end


#------------------------------------------------
# Parse <builtin...
#

class YBuiltin
  def initialize
    @count = 0
    @pending = nil
    @listener = nil
    @symbols = nil
    @name = nil
  end

  def tag_start( name, attrs )
    return @listener.tag_start( name, attrs ) if @listener
    debug "#{self}.tag_start(#{name}) @listener #{@listener}"
    if (@pending == :expression) then
      $output.o( :sep ) if (@count > 0)
      @listener = YExpression.new
      @pending = nil
      return @listener.tag_start( name, attrs )
    end
    case name
      when "element"
	@pending = :expression
      when "builtin"
	h = Helper.attrs2hash attrs
	if h["sym0"] then
	  @name = h["name"]
	  @symbols = Array.new
	  count = 0
	  loop do
	    s = h["sym"+count.to_s]
	    break unless s
	    $output.o( { :com => s } )
	    @symbols << s.split(" ").last
	    count += 1
	  end
	  @listener = YExpression.new :enclosed
	  @pending = :block
	  $output.o( :po )
	  return true
	end
	if h["ns"] && (!h["ns"].empty?) then
	  $output.o( :ycp => h["ns"] )
	  $output.o( :str => "::" )
	end
	$output.o( :bui )
	$output.o( h["name"] )
	$output.o( :po )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "#{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true if @listener      
      @count += 1
      if @pending == :block then
	@listener = YExpression.new
	$output.o( [ :pc, ".", @name, " {", "|" ] )
	first = true
	@symbols.each { |sym|
	    $output.o( :sep ) unless first
	    $output.o( sym )
	    first = false
	}
	$output.o( [ "|", :eol, :inc ] )
      end
      @pending = :expression
      return true
    end
    case name
      when "builtin"
	if @symbols then
	  $output.o( [ :eol, :dec, "}" ] )
	else
	  $output.o( :pc )
	end
	return false
      when "element"
	@pending = nil
	return true
    end
    raise "#{self}.tag_end(#{name}) UNKNOWN" unless @listener
    return true
  end
end


#------------------------------------------------
# Parse <locale .../>
#

class YLocale
  def initialize
    @listener = nil
  end

  def tag_start( name, attrs )
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "locale"
	h = Helper.attrs2hash attrs
	if h["plural"] then
	  $output.o( { :nlo => [ h["text"], h["plural"] ] } )
	  @listener = YExpression.new
	  $output.o( :pc )
	else
	  $output.o( { :loc => h["text"] } )
	end
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "locale"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end

#------------------------------------------------
# Parse <variable .../>
#

class YVariable
  def tag_start( name, attrs )
    case name
      when "variable"
	h = Helper.attrs2hash attrs
	$output.o( { :var => h["name"] } )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    case name
      when "variable"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return false
  end
end

#------------------------------------------------
# Parse <entry .../>
#

class YEntry
  def tag_start( name, attrs )
    case name
      when "entry"
	h = Helper.attrs2hash attrs
	$output.o( { :var => h["name"] } )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end
  def tag_end( name )
    case name
      when "entry"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return false
  end
end

#------------------------------------------------
# Parse <compare> ... </compare>
#
#
class YCompare
  def initialize
    @listener = nil
    @pending = nil
    @op = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    if (@pending == :expression) then
      @listener = YExpression.new
      @pending = nil
      return @listener.tag_start( name, attrs )
    end
    case name
      when "compare"
	@pending = :lhs
	h = Helper.attrs2hash attrs
	@op = h["op"]
      when "lhs", "rhs"
	@pending = :expression
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "compare"
	raise "Unclosed compare, pending #{@pending}" unless @pending == nil
	debug "xx End of #{self}"
	return false
      when "lhs"
	@pending = :rhs
	$output.o( { :op => @op } )
      when "rhs"
	@pending = nil
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <yepropagate> ... </yepropagate>
#
#
class YEPropagate
  def initialize
    @listener = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "yepropagate"
	@listener = YExpression.new
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "yepropagate"
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <yebracket> ... </yebracket>
#
#
class YEBracket
  def initialize
    @listener = nil
    @current = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}  @current #{@current}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "yebracket"
	@listener = YExpression.new
        @current = :expression
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      unless @listener
	case @current
	  when :expression		# expression ended, continue with list
	    $output.o( ".bracket" )
	    $output.o( :po )
	    @listener = YList.new
	    @current = :list
	  when :list			# list ended, continue with default
	    @listener = YExpression.new
	    @current = :default
	    $output.o( :sep )
	  when :default
	    @current = nil
	    $output.o( :pc )
	end
      end
      return true
    end
    case name
      when "yebracket"
	raise "Unclosed bracket" unless @current == nil
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <yereturn> ...
#
#
class YEReturn
  def initialize
    @listener = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "yereturn"
	@listener = YExpression.new
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "yereturn"
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <ycpcode> ...
#
#
class YcpCode
  def initialize
    @listener = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "ycpcode"
	@listener = YExpression.new
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "ycpcode"
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <yeis> ...
#
#
class YEIs
  def initialize
    @listener = nil
    @type = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "yeis"
	h = Helper.attrs2hash attrs
	@type = h["type"]
	@type = "hash" if @type == "map"
	@listener = YExpression.new :enclosed
	$output.o( :po )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "yeis"
	$output.o( :pc )
	$output.o( ".class == " << @type.capitalize )
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <yetriple>
#
#
class YETriple
  def initialize
    @listener = nil
    @pending = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "yetriple"
	@pending = :cond
      when "cond", "true", "false"
	@listener = YExpression.new
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "yetriple"
	raise "Unclosed yetriple, pending #{@pending}" unless @pending == nil
	debug "xx End of #{self}"
	return false
      when "cond", "true"
	$output.o( " ? " ) if name == "cond"
	$output.o( " : " ) if name == "true"
	@pending = nil
      when "false"
	@listener = nil
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
#
# YExpression listener
# Listens to tags specifying an expression
#   if tag_end returns false, tear down listener
#
# Expressions dont have an enclosing tag, their listeners
#  define the end
#
class YExpression
  def initialize kind = :pure		# or :enclosed, for statements
    @listener = nil
    @kind = kind
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "expr"
	return @kind == :enclosed
      when "const"
	@listener = YConstant.new
      when "list"
	@listener = YList.new
      when "map"
	@listener = YMap.new
      when "yeunary"
	@listener = YEUnary.new
      when "yebinary"
	@listener = YEBinary.new
      when "call"	
	@listener = YCall.new
      when "yeterm"
	@listener = YETerm.new
      when "builtin"
	@listener = YBuiltin.new
      when "locale"
	@listener = YLocale.new
      when "variable"
	@listener = YVariable.new
      when "compare"
	@listener = YCompare.new
      when "yepropagate"
	@listener = YEPropagate.new
      when "yebracket"
	@listener = YEBracket.new
      when "entry"
	@listener = YEntry.new
      when "yereturn"
	@listener = YEReturn.new
      when "block"
	@listener = YBlock.new "expr"
      when "yetriple"
	@listener = YETriple.new
      when "ycpcode"
	@listener = YcpCode.new
      when "yeis"
	@listener = YEIs.new
      else
	raise "#{self}.tag_start(#{name}) UNHANDLED"
    end
    @listener.tag_start( name, attrs )
  end

  def text( text )
    $output.o( { :com => "YExpression text >" << text << "< @listener #{@listener}" } )
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then			# const, list, map, ...
      @listener = nil unless @listener.tag_end( name )
      return true if @listener
      return true if @kind == :enclosed		# wait for </expr>
      return false unless @listener		# pure end
    end
    debug "xx End of expression #{self}: #{name}, kind #{@kind}"
    case name
      when "expr"
	return false if @kind == :enclosed
	raise "#{self}: Unenclosed </expr>"
      else
	raise "#{self}.tag_end(#{name}) UNHANDLED"
    end
    return false
  end
end


