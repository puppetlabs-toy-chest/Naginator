#!/usr/local/bin/ruby -w

#--------------------
# A script to retrieve hosts from ldap and create an importable
# cfservd file from them
#
# $Id: object.rb,v 1.4 2004/07/15 15:57:47 luke Exp $

require 'digest/md5'
require 'nagios/object.rb'

module Nagios
	class Object
		@@objects = Array.new
		@@subobjects = Hash.new
		@params = nil # class instance variable
		@derivatives = Hash.new { |object,klass| raise "No class #{object}" }

		def Object.[](name)
			@instances[name]
		end

		def Object.[]=(name,value)
			@instances[name] = value
		end

		def Object.attached
			if defined? @att and ! @att.nil?
				return @att
			else
				return false
			end
		end

		def Object.aux
			return @aux
		end

		def Object.create(name,hash)
			@derivatives[name].new(hash)
		end

		def Object.derivatives
			return @derivatives
		end

		def Object.each
			@instances.each { |name,instance|
				yield name, instance
			}
		end

		def Object.inherited(sub)
			classname = sub.to_s                                                     
			classname.gsub!(/Nagios::/i, '')                                       
			classname.downcase!                                                      
			@derivatives[classname] = sub                                            
			sub.init
		end 

		def Object.init
			@instances = Hash.new
		end

		def Object.map
			if defined? @map
				return @map
			else
				return nil
			end
		end

		def Object.objects
			return @@objects
		end

		def Object.ocs
			if defined? @ocs
				return @ocs
			else
				return nil
			end
		end

		def Object.params
			return @params
		end

		def Object.suppress
			unless defined? @suppress
				@suppress = Hash.new
			end
			return @suppress
		end
		#------------------------------------

		#------------------------------------
		def [](param)
			if param.class == String
				param = param.intern
			end
			if param == :name
				return @params[self.namevar]
			else
				return @params[param]
			end
		end
		#------------------------------------

		#------------------------------------
		def []=(param,value)
			if param.class == String
				param = param.intern
			end
			if param == :name
				@params[self.namevar] = value
			else
				@params[param] = value
			end
		end
		#------------------------------------

		#------------------------------------
		def children
			return @children
		end
		#------------------------------------

		#------------------------------------
		def dn
			base = "dc=madstop,dc=com"

			# yay, the difference between a string and a number...
			if @params.include?(:register) and @params[:register] == "0"
				return "cn=" + self.name + ",ou=nagios,ou=config," + base
			else
				if self.class.attached
					start = self.parent.dn
					return "cn=" + self.name + "," + start 
				else
					return "cn=" + self.name + ",ou=" + 
						self.class.to_s.sub(/Nagios::/,'') + "s," + base
				end
			end
		end
		#------------------------------------

		#------------------------------------
		def each
			@params.each { |param,value|
				yield(param,value)
			}
		end
		#------------------------------------

		#------------------------------------
		def include?(param)
			@params.include?(param)
		end
		#------------------------------------

		#------------------------------------
		def name
			self[self.namevar]
		end
		#------------------------------------

		#------------------------------------
		def namevar
			return (self.type + "_name").intern
		end
		#------------------------------------

		#------------------------------------
		def parammap(param)
			unless defined? @map
				map = {
					self.namevar => "cn"
				}
				if self.class.map
					map.update(self.class.map)
				end
			end
			if map.include?(param)
				return map[param]
			else
				return "nagios-" + param.id2name.gsub(/_/,'-')
			end
		end
		#------------------------------------

		#------------------------------------
		def parent
			unless defined? self.class.attached
				puts "Duh, you called parent on an unattached class"
				return
			end

			klass,param = self.class.attached
			unless @params.include?(param)
				puts "Huh, no attachment param"
				return
			end
			klass[@params[param]]
		end
		#------------------------------------

		#------------------------------------
		def push(object)
			@children.push object
		end
		#------------------------------------

		#------------------------------------
		# okay, this sucks
		# how do i get my list of ocs?
		def to_ldif
			base = "dc=madstop,dc=com"
			str = self.dn + "\n"
			ocs = Array.new
			if self.class.ocs
				# i'm storing an array, so i have to flatten it and stuff
				kocs = self.class.ocs
				ocs.push(*kocs)
			end
			ocs.push "top"
			oc = self.class.to_s
			oc.sub!(/Nagios/,'nagios')
			oc.sub!(/::/,'')
			ocs.push oc
			ocs.each { |oc|
				str += "objectclass: " + oc + "\n"
			}
			@params.each { |name,value|
				if self.class.suppress.include?(name)
					next
				end
				ldapname = self.parammap(name)
				str += ldapname + ": " + value + "\n"
			}
			str += "\n"
			str
		end
		#------------------------------------

		#------------------------------------
		def to_s
			str = "define #{self.type} {\n"

			self.each { |param,value|
				str += %{\t%-30s %s\n} % [ param.id2name, value ]
			}

			str += "}\n"

			if defined? @children
				@children.each { |object|
					str += object.to_s
				}
			end

			str
		end
		#------------------------------------

		#------------------------------------
		def type
			unless defined? @type
				@type = self.class.to_s
				@type.gsub!(/nagios::/i, '')
				@type.downcase!
			end
			return @type
		end
		#------------------------------------

		#------------------------------------
		def initialize(args)
			@params = Hash.new { |param,value|
				puts "failed on #{param.inspect}"
				raise "No parameter #{value} in #{self.class}"
			}

			if defined? args
				args.each { |param,value|
					self[param] = value
				}
			end
			@@objects.push self

			# slap our object into the list of instances
			self.class[self[:name]] = self
			#@@subobjects[self.class].push self
		end
		#------------------------------------
	end
	#------------------------------------------------------------
	# end of object virtual class
	#------------------------------------------------------------

	#------------------------------------------------------------
	# object types
	#------------------------------------------------------------
	class Command < Object
		@params = [ :command_name, :command_line ]
	end

	class Contact < Object
		@params = [
			:contact_name, :alias, :host_notification_period,
			:host_notification_commands, :service_notification_period,
			:service_notification_commands,
			:email, :pager, :service_notification_options, :host_notification_options
		]
	end

	class Contactgroup < Object
		@params = [ :contactgroup_name, :alias, :members ]
	end

	class Host < Object
		@params = [
			:host_name, :notifications_enabled, :event_handler_enabled,
			:flap_detection_enabled, :process_perf_data, :retain_status_information,
			:retain_nonstatus_information, :register, :use, :alias,
			:address, :check_command, :max_check_attempts, :notification_interval,
			:notification_period, :notification_options
		]
		@ocs = [ "ipHost" ]
		@map = {
			:address => "ipHostNumber"
		}

		def initialize(args)
			super(args)
			
			@children = Array.new
			self.class[self.name] = self
		end
	end

	class Hostextinfo < Object
		@aux = true
		@params = [
			:host_name, :notes_url, :icon_image, :icon_image_alt, :vrml_image,
			"2d_coords".intern, "3d_coords".intern
		]

		def namevar
			return :host_name
		end
	end

	class Hostgroup < Object
		@params = [
			:hostgroup_name, :alias, :contact_groups, :members
		]
	end

	class Hostgroupescalation < Object
		@aux = true
		@params = [
			:hostgroup_name, :first_notification, :last_notification,
			:contact_groups, :notification_interval
		]

		def namevar
			return :hostgroup_name
		end
	end

	class Service < Object
		@att = [Nagios::Host, :host_name]
		@params = [
			:name, :active_checks_enabled, :passive_checks_enabled, :parallelize_check,
			:obsess_over_service, :check_freshness, :notifications_enabled,
			:event_handler_enabled, :flap_detection_enabled, :process_perf_data,
			:retain_status_information, :retain_nonstatus_information, :register,
			:is_volatile, :check_period, :max_check_attempts, :normal_check_interval,
			:retry_check_interval, :contact_groups, :notification_interval,
			:notification_period, :notification_options, :service_description,
			:host_name, :freshness_threshold
		]

		@suppress = [ :host_name ]

		def namevar
			return :service_description
		end

		def initialize(args)
			super(args)

			# this is a nice idea, but it complicates a bunch of other
			# things
			# so, disabled for now
			#if @params.include?(:host_name)
			#	Nagios::Host[self[:host_name]].push self
			#end
		end
	end

	class Servicedependency < Object
		@aux = true
		@params = [
			:host_name, :service_description, :dependent_host_name,
			:dependent_service_description, :execution_failure_criteria,
			:notification_failure_criteria
		]

		def namevar
			return :host_name
		end
	end

	class Serviceextinfo < Object
		@aux = true
		@params = [
			:host_name, :service_description, :icon_image, :icon_image_alt
		]

		def namevar
			return :host_name
		end
	end

	class Timeperiod < Object
		@params = [
			:timeperiod_name, :alias, :sunday, :monday, :tuesday, :wednesday,
			:thursday, :friday, :saturday
		]
	end
	#------------------------------------------------------------
	#
	#------------------------------------------------------------
end
