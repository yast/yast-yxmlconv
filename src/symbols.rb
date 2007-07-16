#
# symbols.rb
#

require 'helper'

#------------------------------------------------
# Parse <symbol> ... </symbol>
#
#
class YSymbol
  def symbolhash h
    case h["category"]
      when "filename"
	"Filename #{h['name']}"
      when "variable"
	"#{h['type']} #{h['name']}"
      when "module"
	"Module #{h['name']}"
      when "function"
	"#{h['type']} #{h['name']}"
      else
	"Unhandled category #{h['category']}"
    end
  end

  def initialize kind = nil
    @kind = kind 		 # :module, :definition, :declaration
  end

  def tag_start( name, attrs )
    debug "#{self}.tag_start(#{name})"
    case name
      when "symbol"
	h = Helper.attrs2hash attrs
	$output.o( { :com => symbolhash( h ) } ) if @kind == :module
	$output.o( { :com => h["type"] << "  " << h["name"] } ) if @kind == :definition || @kind == :declaration
	$output.o( { :var => h["name"] } ) if @kind == :declaration
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "#{self}.tag_end(#{name})"
    case name
      when "symbol"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
#
# Symbols listener
# Listens to tags within <symbols>...</symbols>
#   if tag_end returns false, tear down listener

class Symbols
  def initialize kind
    debug "#{self}.new kind #{kind}"
    @listener = nil
    @count = 0
    @kind = kind 		 # :module, :definition, :declaration, see YBlock
    @pending = nil
  end

  def tag_start( name, attrs )
    debug "#{self.class}.tag_start(#{name}) @listener #{@listener} @count #{@count}"
    if @pending == :symbol then
      @listener = YSymbol.new @kind
      @pending = nil
      case @kind
	when :definition, :module
	  $output.o( :com ) if @count > 0
	when :declaration
	  $output.o( :po ) if @count == 0
	  $output.o( :sep ) if @count > 0
      end
    end
    unless @listener then
      case name
        when "symbols"
	  @pending = :symbol
	  return true
	else
	  if @kind == :definition		# dont accept, symbols is optional
	    return false 
	  end
	  raise "#{self}.tag_start(#{name}) UNHANDLED"
      end
    end
    return @listener.tag_start( name, attrs )
  end

  def tag_end( name )
    debug "#{self.class}.tag_end(#{name}) @listener #{@listener} @kind #{@kind}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      unless @listener then
	@count += 1
	@pending = :symbol
      end
      return true
    end
    case name
      when "symbols"
	if @kind == :declaration
	  $output.o( :pc )
	  $output.o( :eol )
	end
	   $output.o( { :com => "Symbols done" } )
	return false
      else
	raise "#{self}.tag_end(#{name}) UNHANDLED"
    end
    return true				# this listener has its own end tag
  end
end
