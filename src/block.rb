#
# Block
#

require 'helper'
require 'statements'
require 'expressions'

#------------------------------------------------
# Parse <block> ... </block>
#
#
class YBlock
  def initialize kind = nil
    @listener = nil
    @kind = kind		# "defstmt", "def", "stmt", "decl", "file", "expr"
    @current = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener} @kind #{@kind} @current #{@current}"
    if @listener then
      result = @listener.tag_start( name, attrs )
      return result if result			# listener accepted
      if @kind == "def" || @kind == "stmt" || @kind == "expr"	# optional symbols not found, go on with statements
	@listener = Statements.new
	@current = :statements
	return @listener.tag_start( name, attrs )
      end
    end
    case name
      when "block"
	h = Helper.attrs2hash attrs
	@kind = h["kind"] unless @kind
	case @kind
	  when "defstmt"
	    @listener = Statements.new
	    @current = :statements
	  when "def", "stmt", "expr"
	    @listener = Symbols.new :definition
	    @current = :symbols
	  when "decl"
	    @listener = Symbols.new :declaration
	    @current = :symbols
	  when "file"
	    @listener = Symbols.new :module
	    @current = :symbols
	  when "module"
	    $output.o( [ "module ", h["name"], :eol, :inc ] )
	    @listener = Symbols.new :module
	    @current = :symbols
	  else
	    raise "Unhandled kind #{@kind} in <block>"
	end
      else
	raise "#{self}.tag_start(#{name}) kind #{@kind}, current #{@current} UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener} @kind #{@kind} @current #{@current}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      unless (@listener) then					# listener just finished
	if @current == :symbols	&& @kind != "decl"		# symbols finished, continue with statements
	  @listener = Statements.new
	  @current = :statements
	end
      end
      return true
    end
    case name
      when "block"
	$output.o( :end ) if @kind == "module"
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}), @kind #{@kind} UNKNOWN"
    end
    return true
  end
end
