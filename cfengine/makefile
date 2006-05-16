# $Id$

BIN = bin/localdisks
INPUTS = inputs/nagios1.cf inputs/nagios2.cf inputs/packages/nagios.cf
#MODULES = modules/module\:nagios
MODULES = "modules/module:nagios"

SVNROOT = /home/luke/svn/apps/cfengine/

ALL = ${BIN} ${INPUTS} ${MODULES}
DEPENDS = ${addprefix ${SVNROOT}, ${BIN} ${INPUTS} ${MODULES}}
BINDEPENDS = ${addprefix ${SVNROOT}, ${BIN}}
INPUTSDEPENDS = ${addprefix ${SVNROOT}, ${INPUTS}}
#MODULESDEPENDS = ${addprefix ${SVNROOT}, ${MODULES}}
MODULESDEPENDS = ${SVNROOT}/modules/*

# a stupid hack to deal with the module, because it has a : in its name
all: ${BIN} ${INPUTS}
	cp ${SVNROOT}/modules/module:nagios modules

bin: ${BIN}

inputs: ${INPUTS}

${BIN}: ${BINDEPENDS}
	@echo making $@
	cp ${SVNROOT}/${@} $@
${INPUTS}: ${INPUTSDEPENDS}
	@echo making $@
	cp ${SVNROOT}/${@} $@
