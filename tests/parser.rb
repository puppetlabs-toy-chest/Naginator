#!/usr/bin/env ruby

$base = File.join(File.dirname(__FILE__), "..")

$:.unshift File.join($base,"lib") if __FILE__ == $0 # Make this library first!

require 'test/unit'

require 'nagios'

$datadir = File.join($base, "tests", "data")

class TestParser < Test::Unit::TestCase
    # Verify that our params are available as attributes.
    def test_simple
        assert(FileTest.directory?($datadir), "Could not find datadir")

        parser = nil
        assert_nothing_raised {
            parser = Nagios::Parser.new
        }

        Dir.entries($datadir).each do |entry|
            next unless entry =~ /\.cfg$/
            file = File.join($datadir, entry)

            results = nil
            assert_nothing_raised("Could not parse %s" % entry) {
                results = parser.parse(File.read(file))
            }

            results.each do |obj|
                assert(obj.is_a?(Nagios::Base), "Object does not derive from base")
            end


        end
        host = nil
        assert_nothing_raised {
            host = Nagios::Base.create(:host)
        }

        assert_nothing_raised {
            host.notifications_enabled = true
        }

        assert(host.respond_to?(:notifications_enabled),
            "Did not define method")

        assert_raise(NoMethodError) do
            host.nosuchattribute = false
        end
    end
end

# $Id$
