#!/usr/local/bin/ruby -w

#--------------------
# create a nagios schema from the parameter entries
#
# $Id: mkschema.ruby,v 1.1 2004/03/04 03:18:49 luke Exp $

# this is some nastiness; how do i add a lib directory for ruby?
require 'getoptlong'

# a small hack; yay
begin
	require 'nagios.rb'
rescue LoadError
	puts "duh: export RUBYLIB=~/cvs/nagios/generation/lib/ruby/"
	exit
end

result = GetoptLong.new(
	[ "--help",		"-h",            GetoptLong::NO_ARGUMENT ]
)

module Fun
	@@length = 70

	def Fun.pprint(string)
		strings = Array.new
		newstring = ""

		while string.size > 0
			string.sub!(/(\S+)(\s+|$)/,'')
			chunk = $1
			if chunk.nil?
				break
			end
			if newstring.size + chunk.size > @@length
				strings.push newstring
				newstring = chunk
			else
				newstring += " " + chunk
			end
		end
		strings.push newstring

		return strings.join("\n\t\t")
	end
end

module Mib
	@@base = "1.1.1.1"
	@@incr = 0

	def Mib.next
		@@incr += 1
		return "#{@@base}.#{@@incr}"
	end
end

#def Object.nextmib
#	@incr += 1
#	return "#{@base}.#{@incr}"
#end

class Attribute
	attr_reader :name

	@@attrs = Hash.new

	def Attribute.create(attr)
		name = attr.id2name
		unless @@attrs.include?(name)
			Attribute.new(name)
		end
	end

	def Attribute.to_s
		#@@attrs.sort!
		return @@attrs.sort.collect { |attr,obj|
			obj.to_s
		}.join('')
	end

	def <=>(other)
		self.name <=> other.name
	end

	def initialize(attr)
		@@attrs[attr] = self

		@name = attr
		@mib = Mib.next
	end

	def to_s
		return %{attributetype ( #{@mib} NAME '#{"nagios_" + @name}'
	DESC 'Nagios Attribute #{@name}'
	EQUALITY caseIgnoreIA5Match
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 SINGLE-VALUE )

}
	end
end

class Objectclass
	attr_reader :name

	@@classes = Array.new

	def <=>(other)
		self.name <=> other.name
	end

	def Objectclass.to_s
		#@@classes.sort!
		@@classes.sort.each { |klass|
			klass.to_s
		}
	end

	def initialize(oc,ary)
		@@classes.push self
		@mib = Mib.next
		@name = oc
		@params = ary.collect { |param| "nagios_" + param.id2name }
	end

	def to_s
		return %{objectclass ( #{@mib} NAME '#{"nagios_" + @name}' SUP top AUXILIARY
	DESC 'Nagios Class #{@name}'
	MAY ( } + Fun.pprint(@params.sort.join(' $ ') + " ) )") + "\n\n"
	end
end

attrs = Array.new

Nagios::Object.derivatives.each{ |object,klass|

	Objectclass.new(object,klass.params)

	klass.params.each { |param|
		Attribute.create(param)
		#attrs.push param
	}
}

puts Attribute.to_s
print "\n"
puts Objectclass.to_s
