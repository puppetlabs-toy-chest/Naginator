all: config

generate:
	sudo /home/luke/cvs/config/apps/cfengine/modules/module\:nagios -g solaris:home -s 'ssh:local_disk!/var/run:local_disk!/' -r /etc/nagios/remote.cfg -l /etc/nagios/local.cfg

collect: generate
	sudo /home/luke/cvs/nagios/generation/bin/nagcollect kirby culain

config: collect
	sudo /home/luke/cvs/nagios/generation/bin/nagconfig -d /tmp/collection --outfile /etc/nagios/generated.cfg

culain:
	sudo /home/luke/cvs/config/apps/cfengine/modules/module\:nagios -g linux:home -s 'ssh:local_disk!/data:local_disk!/:local_disk!/dev' -r /etc/nagios/remote.cfg -l /etc/nagios/local.cfg
