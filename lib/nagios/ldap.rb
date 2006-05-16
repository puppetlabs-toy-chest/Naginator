#!/usr/local/bin/ruby -w

#--------------------
# convert ldap entries to nagios objects
#
# $Id: ldap.rb,v 1.1 2004/06/09 20:32:46 luke Exp $

require 'digest/md5'
require 'nagios/object.rb'
require 'ldap'

module LDAP
	class Entry
		@oc2object = {
			:iphost => Nagios::Host
		}
		def Entry.oc2class(oc)
			tmp = oc.downcase.intern
			if @oc2object.has_key?(tmp)
				return @oc2object[tmp]
			end
			return nil
		end

		def entry2nagios
			# i need to figure out which object to create from the 
			klass = nil
			#puts self.vals("objectclass").class
			#puts self.vals["objectclass"].class
			#return
			self.vals("objectclass").each { |oc|
				next if klass
				klass = self.class.oc2class(oc)
			}

			if klass == nil
				raise "No mapping available for #{self.dn}"
			end

			# okay, we've got the class
			# now we just need per-class mappings for attribute to nag var
			hash = {}
			self.attrs.each { |attr|
				if nagattr = klass.attrmap(attr)
					hash[nagattr] = self.vals(attr)
				end
			}

			# now we've got a hash with all the right values, so...
			begin
				object = klass.new(hash)
			rescue
				puts "could not create object"
			end
			
			return object
		end
	end
end

module Nagios
	class Object
		def Object.attrmap(attr)
			if attr =~ /nagios-/
				return attr.sub(/nagios-/,"").intern
			end
			if @attribute2nag.has_key?(attr.downcase)
				return @attribute2nag[attr.downcase]
			else
				return nil
			end
		end
	end

	class Host
		@attribute2nag = {
			"cn" => :host_name,
			"iphostnumber" => :address
		}
	end
end
