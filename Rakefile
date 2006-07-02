# Rakefile for Naginator

begin
    require 'rake/reductive'
rescue LoadError
    $stderr.puts "You must have the Reductive build library in your RUBYLIB."
    exit(14)
end

dir = File.dirname(__FILE__)
$: << File.join(dir, "lib")

require 'nagios'

TESTHOSTS = %w{rh3a fedora1 centos1 freebsd1 culain}

project = Rake::RedLabProject.new("nagios", Nagios::NAGIOSVERSION) do |p|
    p.summary = "Ruby libraries for Nagios, including a parser"
    p.description = "Naginator is a set of support libraries for managing Nagios
        from within Ruby.  It includes a parser, so it is easy to get information
        into Nagios, and generators, so you can easily create new Nagios configuration
        files."


    p.filelist = [
        'install.rb',
        '[A-Z]*',
        'lib/**/*.rb',
        'test/**/*.rb',
        'bin/**/*',
        'ext/**/*',
        'examples/**/*',
        'etc/**/*'
    ]
end

begin
if project.has?(:gem)
    # Make our gem task.  This actually just fills out the spec.
    project.mkgemtask do |task|

        task.require_path = 'lib'                         # Use these for libraries.

        task.bindir = "bin"                               # Use these for applications.
        task.executables = %w{mkschema nagaccept nagcollect nagconfig nagkeys
            nagsend}
        task.default_executable = "nagcollect"
        task.autorequire = 'nagios'

        #### Documentation and testing.

        task.has_rdoc = true
        #s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
        task.rdoc_options <<
            '--title' <<  'Naginator - Automated Nagios Management' <<
            '--main' << 'README' <<
            '--line-numbers'
        #task.test_file = "test/test"
    end
end
rescue => detail
puts detail.backtrace
puts detail
exit
end

#if project.has?(:epm)
#    project.mkepmtask do |task|
#        task.bins = FileList.new("bin/puppet", "bin/puppetca")
#        task.sbins = FileList.new("bin/puppetmasterd", "bin/puppetd")
#        task.rubylibs = FileList.new('lib/**/*')
#    end
#end

# $Id$
