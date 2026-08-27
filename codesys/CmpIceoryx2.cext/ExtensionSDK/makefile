##############################################################################
#	Copyright:		Copyright CODESYS Development GmbH
#	Program:		Extension API for the Linux SL products
##############################################################################

ifeq ($(dir $(lastword $(MAKEFILE_LIST))), ./)
#
# MAKEFILE is used wrong! Never call it from this folder directly
#
.PHONY:help
help:
	@echo "**********************"	
	@echo "Dont work inside this folder! Please go to your library folder and call this makefile e.g.:"
	@echo "make -f ../sdk/makefile newproject"
	@echo 
	@echo "**********************"	

.PHONY:all
all: help

.PHONY:newproject
newproject: help

.PHONY:makefile
makefile: help

else
#
# NORMAL RULES
#

# get some info from generated files
ITFM4 = $(wildcard *Itf.m4)
CSRC = $(wildcard *.c)
CMPBASENAME=$(CSRC:.c=)

# set some variables
OUTDIR=./out
ITF = $(basename ${ITFM4})
TEMPLATEDEP = $(SDKDIR)/m4/TemplateDep.m4
DEP = ${CMPBASENAME}Dep


# set name of shared object
SONAME= lib${CMPBASENAME}.so

# set sources of component
SRC += ${CSRC} CmpFrame.c

# objects: all sources
OBJS = $(addprefix ${OUTDIR}/,$(SRC:.c=.o))

# set default includes
INCLUDES += -I${SDKDIR}/include/ -I${OUTDIR}/ -I.
CFLAGS += -fPIC -g -O0 -Wall -Wextra -Wno-unused
CFLAGS += -DDEP_H=\"${DEP}.h\"

# set a vendorID
CMPVENDORID=0xFFFF

vpath %.m4 ${SDKDIR}/cmpstub/
vpath %.c  ${SDKDIR}/src/

.PHONY:help
help:
	@echo "**********************"	
	@echo "help / usage / available make targets:"
	@echo "-all        : just do everything needed"
	@echo "-clean      : cleanup all generated files"
	@echo "-newproject : create a new project"
	@echo "-showenv    : show intern variables (for debugging)"
	@echo "**********************"


.PHONY:newproject
newproject: makefile

.PHONY:all
all: ${OUTDIR}/$(SONAME)

SDK_BASE=$(dir $(lastword $(MAKEFILE_LIST)))

.PHONY:showenv
showenv:
	@echo "**********************"	
	@echo "ITFM4:         ${ITFM4}"
	@echo "CSRC:          ${CSRC}"	
	@echo "SONAME:        ${SONAME}"
	@echo "ITF:           ${ITF}"
	@echo "DEP:           ${DEP}"
	@echo "OBJS:          ${OBJS}"
	@echo "CC:            $(CC)"
	@echo "CFLAGS:        ${CFLAGS}"
	@echo "SDKDIR:        ${SDKDIR}"
	@echo "CMPBASENAME:   ${CMPBASENAME}"
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "**********************"
	@echo ""

# check if there are whitespaces in the SDK BASE DIR
# this causes horrible things in make, so we detect/avoid it directly at creating a new project
ifeq (1,$(words $(MAKEFILE_LIST)))
makefile:
	@echo "**********************"
	@echo "creating makefile for your project "
	cp ${SDK_BASE}/makefile_template $@
	@echo "# include of the SDK makefiles" >>  $@
	@echo "SDKDIR="$(abspath ${SDK_BASE}) >>  $@
	@echo 'include $${SDKDIR}/makefile' >>  $@
	@echo "" >>  $@
	@echo "now check your makefile here"
	@echo "**********************"
	@echo ""

else
makefile:
	@echo "**********************"
	@echo "creating makefile for your project FAILED:"
	@echo "there are whitespaces in the SDK path"
	@echo "this does not work with 'make'!"	
	@echo "Please put your SDK to a path without whitespaces"
	@echo "**********************"
	@echo ""
	
endif

${OUTDIR}/%.o: %.c
	@echo "**********************"
	@echo "compile: $@ from $<"
	@mkdir -p ${OUTDIR}
	$(CC)  -c $(CFLAGS) $(INCLUDES) -o $@  $<
	@echo "**********************"
	@echo ""

${OUTDIR}/${SONAME}: ${OUTDIR}/$(DEP).h ${OUTDIR}/$(ITF).h $(OBJS)
	@echo "**********************"
	@echo "link: $@"
	@mkdir -p ${OUTDIR}
	$(CC)  $(LDFLAGS) -shared $(OBJS) -Wl,-soname,$(SONAME) -o $@ $(LDLIBS)
	@echo "**********************"
	@echo ""

${OUTDIR}/$(DEP).m4:
	@echo "**********************"
	@echo "create $@ from template"
	@mkdir -p ${OUTDIR}
	echo 'SET_COMPONENT_NAME(`'${CMPBASENAME}"')" > $@
	echo 'COMPONENT_VERSION(`'${CMPVERSION}"')" >> $@
	echo 'COMPONENT_VENDORID(`'${CMPVENDORID}"')" >> $@
	echo "#define CMPID_${CMPBASENAME}		${CMPID}" >> $@
	echo "IMPLEMENT_ITF("'`'"${CMPBASENAME}Itf.m4')" >> $@	
	@echo "**********************"
	@echo ""

${OUTDIR}/$(DEP).h: ${OUTDIR}/$(DEP).m4 $(ITF).m4
	@echo "**********************"
	@echo "build dependency header: $@ from $<"	
	@mkdir -p ${OUTDIR}
	$(DOS2UNIX) $<
	$(M4) -I$(SDKDIR)/m4 -I. Implementation.m4 - < $< > $@
	@echo "**********************"
	@echo ""

${OUTDIR}/$(ITF).h: $(ITF).m4
	@echo "**********************"
	@echo "build interface header: $@ from $<"
	@sed -n '/DEF_API/ !d; /_cext/ ! { s/^/ERROR: This functionname does not contain _cext (this is mandatory, see help for details):\n/p;q 1}' $<
	@mkdir -p ${OUTDIR}
	$(DOS2UNIX) $<
	$(M4) -I$(SDKDIR)/m4 Exports.m4 - < $< > $@
	@echo "**********************"
	@echo ""

.PHONY:clean
clean:
	@echo ""
	@echo "**********************"
	@echo "clean up"
	rm -rf ${OUTDIR};
	@echo "**********************"
	@echo ""

endif
