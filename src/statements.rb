#
# Statements
#

require 'helper'
require 'block'
require 'expressions'

#------------------------------------------------
# Parse <break... />
#
class YBreak
  def tag_start( name, attrs )
    case name
      when "break"
	$output.o( "break" )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
  def tag_end( name )
    case name
      when "break"
	return false
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
end

#------------------------------------------------
# Parse <continue... />
#
class YContinue
  def tag_start( name, attrs )
    case name
      when "continue"
	$output.o( "next" )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
  def tag_end( name )
    case name
      when "continue"
	return false
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
end

#------------------------------------------------
# Parse <filename... />
#
class YFilename
  def tag_start( name, attrs )
    case name
      when "filename"
	h = Helper.attrs2hash attrs
	$output.o( { :com => "filename: " << h["name"] } )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
  def tag_end( name )
    case name
      when "filename"
	return false
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
end

#------------------------------------------------
# Parse <import ... />
#
class YImport
  def tag_start( name, attrs )
    case name
      when "import"
	h = Helper.attrs2hash attrs
	$output.o( { :imp => h["name"] } )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
  def tag_end( name )
    case name
      when "import"
	return false
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
end

#------------------------------------------------
# Parse <include ... />
#
class YInclude
  def tag_start( name, attrs )
    case name
      when "include"
	h = Helper.attrs2hash attrs
	$output.o( { :com => "include " << h["name"] } )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
  def tag_end( name )
    case name
      when "include"
	return false
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
end

#------------------------------------------------
# Parse <textdomain ... />
#
class YTextdomain
  def tag_start( name, attrs )
    case name
      when "textdomain"
	h = Helper.attrs2hash attrs
	$output.o( { :tdm => h["name"] } )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
  def tag_end( name )
    case name
      when "textdomain"
	return false
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end
end


#------------------------------------------------
# Parse <if> ... </if>
#
#
class YIf
  def initialize
    @listener = nil
    @pending = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener} @pending #{@pending}"
    return @listener.tag_start( name, attrs ) if @listener
    if (@pending == :expression) then
      @listener = YExpression.new
      @pending = nil
    end
    if (@pending == :statement) then
      @listener = YStatement.new :pure
      @pending = nil
    end
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "if"
	@pending = :expression
	$output.o( "if" )
	$output.o( :po )
      when "then"
	$output.o( [ :pc, " then", :eol, :inc ]  )
	@pending = :statement
      when "else"
	$output.o( [ :eol, :dec, "else", :eol, :inc ] )
	@pending = :statement
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true	# wait for </if>
    end
    case name
      when "if"
	raise "Unclosed if" unless @pending == nil
	debug "xx End of #{self}"
	$output.o( :end )
	return false
      when "then", "else"
	@pending = nil
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <assign> ... </assign>
#
#
class YAssign
  def initialize
    @listener = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "assign"
	h = Helper.attrs2hash attrs
	$output.o( { :var => h["name"] } )
	$output.o( { :op => "=" } )
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
      when "assign"
	raise "Unclosed assign" unless @pending == nil
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <bracket> ... </bracket>
#
#
class YBracket
  def initialize
    @listener = nil
    @pending = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case @pending
      when :expression
	@listener = YExpression.new
	@pending = nil
      when :list
	@listener = YList.new
	@pending = nil
    end
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "bracket"
	@pending = :lhs
      when "lhs"
	@pending = :entry
      when "entry"
	@pending = :arg
	h = Helper.attrs2hash attrs
	$output.o( h["name"] )
      when "arg"
	@pending = :list
      when "rhs"
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
      when "bracket"
	raise "Unclosed bracket" unless @pending == nil
	debug "xx End of #{self}"
	return false
      when "arg", "entry"
	return true
      when "lhs"
	@pending = :rhs
	$output.o( { :op => "=" } )
      when "rhs"
	@pending = nil
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <return> ... </return>
#
# expression is optional, so set up listener _and_ step
#  if tag_start is called again, we have an expression
#  else check in tag_end if we have/had an expression
#    if not, tear down listener and dont call tag_end of listener
#
class YReturn
  def initialize
    @listener = nil
    @step = :before_start	# :before_expr, :during_expr, :after_expr
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @step #{@step} @listener #{@listener}"
    if @step == :before_expr then
      $output.o( " " )
      @step = :during_expr
    end
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "return"
	$output.o( "return" )
	@listener = YExpression.new
	@step = :before_expr
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
    return true
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener && @step != :before_expr) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "return"
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return false
  end
end


#------------------------------------------------
# Parse <declaration> ... </declaration>
#
#
class YDeclaration
  def initialize
    @listener = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "declaration"
	@listener = YBlock.new "decl"
	return true
    end
    $output.o( [ :po, :pc, :eol ] )
    return false		# declaration is optional
  end

  def text( text )
    $output.o( { :com => "YDeclaration text >" << text << "<" } )
    return @listener.text( text ) if @listener
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true
    end
    case name
      when "declaration"
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <fun_def> ... </fun_def>
#
#
class YFunDef
  def initialize
    @listener = nil
    @pending = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    if @listener then
      result = @listener.tag_start( name, attrs )
      return result if result
      if @pending == :declaration then
	@listener = YBlock.new
	@pending = :definition
        return @listener.tag_start( name, attrs )
      end
    end
    case name
      when "fun_def"
	@pending = :declaration
	@listener = YDeclaration.new
	h = Helper.attrs2hash attrs
	$output.o( { :fun => h["name"] } )
      else
	raise "#{self}.tag_start(#{name}) UNKNOWN"
    end
  end

  def text( text )
    $output.o( { :com => "YFunDef text >" << text << "<" } )
    return @listener.text( text ) if @listener
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}, @pending #{@pending}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      unless @listener
	if @pending == :declaration
	  @listener = YBlock.new
	  @pending = nil
	end
      end
      return true
    end
    case name
      when "fun_def"
	$output.o( [ :end, :eol ] )
	debug "xx End of #{self}"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <while> <cond>...</cond> [ <do>...</do> ] </while>
#
# after <do>, either <block> or a statement follow. Ugly.
# And even <do> is optional. More ugly.
#
class YWhile
  def initialize
    @listener = nil
    @pending = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "while"
	@pending = :cond
	$output.o( [ "while", :po ] )
      when "cond"
	@listener = YExpression.new
      when "do"
	@pending = :statement
      when "block"
	if @pending == :statement
	  @listener = YBlock.new
	  return @listener.tag_start( name, attrs )
	end
      else
	if @pending == :statement
	  @listener = YStatement.new :pure
	  return @listener.tag_start( name, attrs )
	end
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
      when "while"
	raise "Unclosed while" unless @pending == nil
	$output.o( :end )
	debug "xx End of #{self}"
	return false
      when "cond"
	$output.o( [ :pc, :eol, :inc ] )	# :end implies :dec
	@pending = :do
      when "do"
	@pending = nil
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <repeat> <do>...</do> <until>...</until> </repeat>
#
# after <do>, either <block> or a statement follow. Ugly.
#
class YRepeat
  def initialize
    @listener = nil
    @pending = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "repeat"
	@pending = :do
      when "until"
	@listener = YExpression.new
	$output.o( [ :eol, "until", :po ] )
      when "do"
	@pending = :statement
	$output.o( [ "repeat", :beg ] )
      when "block"
	if @pending == :statement
	  @listener = YBlock.new "stmt"
	  return @listener.tag_start( name, attrs )
	end
      else
	if @pending == :statement
	  @listener = YStatement.new :pure
	  return @listener.tag_start( name, attrs )
	end
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
      when "repeat"
	raise "Unclosed repeat" unless @pending == nil
	debug "xx End of #{self}"
	return false
      when "do"
	@pending = :until
	$output.o( :end )
      when "until"
	@pending = nil
	$output.o( :pc )
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
# Parse <do>...</do> <until>...</until> </repeat>
#
# after <do>, either <block> or a statement follow. Ugly.
#
class YDo
  def initialize
    @listener = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener}"
    return @listener.tag_start( name, attrs ) if @listener
    case name
      when "do"
	@listener = YBlock.new "stmt"
	$output.o( [ "loop", :do ] )
      when "while"
	$output.o( [ :eol, "break", " unless", :po ] )
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
      when "do"
	$output.o( :end )
	debug "xx End of #{self}"
	return false
      when "while"
	$output.o( :pc )
      else
	raise "#{self}.tag_end(#{name}) UNKNOWN"
    end
    return true
  end
end


#------------------------------------------------
#
# YStatement listener
# Listens to single statements
#   if tag_end returns false, tear down listener

class YStatement
  def initialize kind = :enclosed	# or :pure - without enclosing <stmt>
    @listener = nil
    @kind = kind
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener} @pending #{@pending}"
    unless @listener then
      case name
	when "stmt"
	  raise "<stmt> unenclosed" unless @kind == :enclosed
	  return true
	when "return"
	  @listener = YReturn.new
	when "assign"
	  @listener = YAssign.new
	when "if"
	  @listener = YIf.new
	when "block"
	  @listener = YBlock.new "stmt"
	when "import"
	  @listener = YImport.new
	when "textdomain"
	  @listener = YTextdomain.new
	when "fun_def"
	  @listener = YFunDef.new
	when "expr"
	  @listener = YExpression.new :enclosed
	when "bracket"
	  @listener = YBracket.new
	when "include"
	  @listener = YInclude.new
	when "filename"
	  @listener = YFilename.new
	when "while"
	  @listener = YWhile.new
	when "repeat"
	  @listener = YRepeat.new
	when "do"
	  @listener = YDo.new
	when "continue"
	  @listener = YContinue.new
	when "break"
	  @listener = YBreak.new
	else
	  raise "#{self}.tag_start(#{name}) UNHANDLED"
      end
    end
    return @listener.tag_start( name, attrs )
  end

  def text( s )
    STDERR.puts "#{@listener} text >" << s << "<"
    return @listener.text( s ) if @listener
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener} @kind #{@kind}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return @kind == :enclosed unless @listener	# false if :pure and listener is done
      return true
    end
    raise "#{self}.tag_end(#{name}) UNHANDLED" unless name == "stmt"
    return false
  end
end


#------------------------------------------------
#
# Statements listener
# Handles <statements>...</statements>
#   if tag_end returns false, tear down listener

class Statements
  def initialize
    @listener = nil
    @count = 0
    @pending = nil
  end

  def tag_start( name, attrs )
    debug "++ #{self}.tag_start(#{name}) @listener #{@listener} @count #{@count}"
    if @pending == :statement then
      @listener = YStatement.new 
      @pending = nil
      $output.o( :eol ) if @count > 0
    end
    unless @listener then
      case name
	when "statements"
	  @pending = :statement
	  return true
	else
	  raise "#{self}.tag_start(#{name}) UNHANDLED"
      end
    end
    return @listener.tag_start( name, attrs )
  end

  def text( s )
    return @listener.text( s ) if @listener
  end

  def tag_end( name )
    debug "-- #{self}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      unless @listener then
	@count += 1
	@pending = :statement
      end
      return true
    end
    case name
      when "statements"
	return false
      else
	raise "#{self}.tag_end(#{name}) UNHANDLED"
    end
    return true				# this listener has its own end tag
  end
end
