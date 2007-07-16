#
# Output handler for ycpxml2ruby
#
class Output
  def initialize stream, flags = []
    @indent = 0
    @spaces = ""
    @stream = stream
    @indentation_pending = true
    @comments = nil
    @flag_comments = true
    flags.each { |f|
      @flag_comments = false if f == :no_comments
    }
  end

  def inc
    @indent += 1
    @spaces << "  "
  end

  def dec
    @indent -= 1
    raise "Indentation level < 0" if @indent < 0
    @spaces.chop!
    @spaces.chop!
  end

  def indent
    if @comments then
      @comments.each { |c|
	@stream << @spaces << "# " << c << "\n"
      }
      @comments = nil
    end
    @stream << @spaces
    @indentation_pending = false
  end

  # output newline
  def nl
    @stream << "\n"
    @indentation_pending = true
  end

  # output string
  def str s
    indent() if @indentation_pending
    @stream << s
  end

  def out k, v = nil
    case k
      when :fun
	nl()
	str "def "
	str v
	inc()
      when :beg
	str " begin"
	nl()
	inc()
      when :end
	nl()
	dec()
	str "end"
      when :com
	@comments = Array.new unless @comments
	@comments << v if @flag_comments
      when :inc
	inc()
      when :dec
	dec()
      when :eol
	nl()
      when :str
	str v
      when :var
	str v
      when :bui
	str "Ycp::Builtin::"
      when :typ
	out :com, "Type " << v
      when :po
	str "( "
      when :pc
	str " )"
      when :cbo
	str "{"
	nl()
	inc()
      when :cbc
	nl()
	dec()
	str "}"
	nl()
      when :sep
	str ", "
      when :op
	str " " << v << " "
      when :ycp
	str "Ycp::" << v
      when :loc
	str "_( \"" << v << "\" )"
      when :nlo
	str "_( \"" << v[0] << "\", \"" << v[1] << "\", "
      when :imp
	str "require 'ycp/" << v << "'"
      when :tdm
	str "Ycp::Textdomain '" << v << "'"
      when :do
	str " do"
	nl()
	inc()
      else
	raise "#{self}.out called with unknown key #{k}"
    end
  end

  #
  # output h = String, Symbol, Array or Hash
  #  :fun => "name"		start function definition (implies :beg)
  #  :beg => nil		begin (implies :eol, :inc)
  #  :end => nil		end (implies :eol, :dec)
  #  :com => "comment"		comment (delayed output)
  #  :inc => nil		increment indentation
  #  :dec => nil		decrement indentation
  #  :eol => nil		end-of-line (indent next output)
  #  :str => "string"
  #  :var => "variable"
  #  :bui => "builtin"
  #  :typ => "type"
  #  :po, :pc			Paranthese open, close ( )
  #  :cbo, :cbc			Curly brace open for blocks!, close { }, implies :eol
  #  :op  => "operator"		Infix operator
  #  :ycp => ycp namespace	Ycp::
  #  :loc => "localized text"
  #  :nlo => "localized text with singular/plural", :pc follows
  #  :imp => import
  #  :mod => module
  #  :do => nil			do (implies :eol, :inc)
  #
  def o h
    if h.class == Symbol then
      out h
    else if h.class == String then
      out :str, h
    else if h.class == Array then
      h.each { |v|
	out v, nil if v.class == Symbol
	out :str, v if v.class == String
      }
    else if h.class == Hash then
      raise "Hash does not preserve ordering" if h.size > 1
      h.each { |k,v|
	out k, v
      }
    else
      raise "#{self}.o called with unknown parameter of class #{h.class}"
    end
    end
    end
    end
  end

end

