#
# ycp xml to ruby converter
#

# Based on the rexml stream listener

# Each listener class has @listener to pass on tag_start()
#  and tag_end() callbacks
#
# The chain of @listeners defines the 'state' of the parser
#  inside the XML tree
#  This way, the nested nature of xml can easily be handled
#
# The current XML generated from YaST has some optional
#  xml tags which need a one-token-lookahead strategy.
#  This is implemented by making the tag_start() return
#  boolean.
#
# If tag_start() returns true, this means the current listener
# accepted the tag and is able to handle the complete xml sub-tree
# following that tag.
#
# The xml sub-tree ends when the tag_end() callback returns
# false.
#
#

require 'rexml/document'
require 'output'
require 'helper'
require 'expressions'
require 'statements'
require 'symbols'

#------------------------------------------------
# Parse <ycp>...</ycp>
#
#

class YcpListener

  attr_reader :state

  def initialize( output, flags = [] )
    # :undef, :ycp, :file, :module, :symbols, :statements, :fundef
    @state = :undef
    @listener = nil
    $output = Output.new( output, flags )
    $lnum = 1
  end

  def xmldecl( version, encoding, standalone )
    $ycpversion = version
  end

  def text( s )
    $lnum += s.count( "\n" )
    s.strip!
     return if s.empty?
    return @listener.text( s ) if @listener
  end

  def tag_start( name, attrs )
    debug "++ #{self.class}.tag_start(#{name}) @listener #{@listener}"
    begin
      return @listener.tag_start( name, attrs ) if @listener
    rescue Exception => e
      STDERR.puts "In line #{$lnum}: " + e
      raise e
    end
    out = nil
    case name
      when "ycp"
	@state = :ycp
      when "block"
	@listener = YBlock.new
      else
	raise "YcpListener: Unhandled tag_start '#{name}'"
    end
    @listener.tag_start( name, attrs ) if @listener
  end

  def tag_end( name )
    debug "-- #{self.class}.tag_end(#{name}) @listener #{@listener}"
    if (@listener) then
      @listener = nil unless @listener.tag_end( name )
      return true				# this listener has its own end tag
    end
    case name
      when "ycp": @state = :undef
      when "block": @state = :ycp
      else
	raise "YcpListener: Unhandled tag_end '#{name}'"
    end
  end

end
