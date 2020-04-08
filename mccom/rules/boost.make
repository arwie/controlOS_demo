# -*-makefile-*-
#
# Copyright (C) 2006 by Robert Schwebel
#               2009 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_BOOST) += boost

#
# Paths and names
#
BOOST_VERSION	:= 1_67_0
BOOST_MD5	:= ced776cb19428ab8488774e1415535ab
BOOST		:= boost_$(BOOST_VERSION)
BOOST_SUFFIX	:= tar.bz2
BOOST_URL	:= $(call ptx/mirror, SF, boost/$(BOOST).$(BOOST_SUFFIX))
BOOST_SOURCE	:= $(SRCDIR)/$(BOOST).$(BOOST_SUFFIX)
BOOST_DIR	:= $(BUILDDIR)/$(BOOST)
BOOST_LICENSE	:= BSL-1.0
BOOST_LICENSE_FILES := file://LICENSE_1_0.txt;md5=e4224ccaecb14d942c71d31bef20d78c

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

# boost doesn't provide "no library" choice. If the library list is empty, it
# goes for all libraries. We start at least with date_time lib here to avoid
# this
BOOST_LIBRARIES-y				:= date_time

BOOST_LIBRARIES-$(PTXCONF_BOOST_ATOMIC)		+= atomic
BOOST_LIBRARIES-$(PTXCONF_BOOST_CHRONO)		+= chrono
BOOST_LIBRARIES-$(PTXCONF_BOOST_CONTAINER)	+= container
BOOST_LIBRARIES-$(PTXCONF_BOOST_CONTEXT)	+= context
BOOST_LIBRARIES-$(PTXCONF_BOOST_CONTRACT)	+= contract
BOOST_LIBRARIES-$(PTXCONF_BOOST_COROUTINE)	+= coroutine
BOOST_LIBRARIES-$(PTXCONF_BOOST_DATE_TIME)	+= date_time
BOOST_LIBRARIES-$(PTXCONF_BOOST_EXCEPTION)	+= exception
BOOST_LIBRARIES-$(PTXCONF_BOOST_FIBER)		+= fiber
BOOST_LIBRARIES-$(PTXCONF_BOOST_FILESYSTEM)	+= filesystem
BOOST_LIBRARIES-$(PTXCONF_BOOST_GRAPH)		+= graph
BOOST_LIBRARIES-$(PTXCONF_BOOST_GRAPH_PARALLEL)	+= graph_parallel
BOOST_LIBRARIES-$(PTXCONF_BOOST_IOSTREAMS)	+= iostreams
BOOST_LIBRARIES-$(PTXCONF_BOOST_LOCALE)		+= locale
BOOST_LIBRARIES-$(PTXCONF_BOOST_LOG)		+= log
BOOST_LIBRARIES-$(PTXCONF_BOOST_MATH)		+= math
BOOST_LIBRARIES-$(PTXCONF_BOOST_MPI)		+= mpi
BOOST_LIBRARIES-$(PTXCONF_BOOST_PROGRAM_OPTIONS)+= program_options
BOOST_LIBRARIES-$(PTXCONF_BOOST_PYTHON)		+= python
BOOST_LIBRARIES-$(PTXCONF_BOOST_RANDOM)		+= random
BOOST_LIBRARIES-$(PTXCONF_BOOST_REGEX)		+= regex
BOOST_LIBRARIES-$(PTXCONF_BOOST_SERIALIZATION)	+= serialization
BOOST_LIBRARIES-$(PTXCONF_BOOST_SIGNALS)	+= signals
BOOST_LIBRARIES-$(PTXCONF_BOOST_STACKTRACE)	+= stacktrace
BOOST_LIBRARIES-$(PTXCONF_BOOST_SYSTEM)		+= system
BOOST_LIBRARIES-$(PTXCONF_BOOST_TEST)		+= test
BOOST_LIBRARIES-$(PTXCONF_BOOST_THREAD)		+= thread
BOOST_LIBRARIES-$(PTXCONF_BOOST_TIMER)		+= timer
BOOST_LIBRARIES-$(PTXCONF_BOOST_TYPE_ERASURE)	+= type_erasure
BOOST_LIBRARIES-$(PTXCONF_BOOST_WAVE)		+= wave

BOOST_PATH	:= PATH=$(CROSS_PATH)
BOOST_CONF_TOOL	:= NO
BOOST_CONF_OPT	:= \
	--with-toolset=gcc \
	--prefix="$(PKGDIR)/$(BOOST)/usr"

BOOST_ABI	:= sysv
ifneq ($(PTXCONF_ARCH_ARM)$(PTXCONF_ARCH_ARM64),)
BOOST_ARCH	:= arm
BOOST_ABI	:= aapcs
endif
ifdef PTXCONF_ARCH_X86
BOOST_ARCH	:= x86
endif
ifdef PTXCONF_ARCH_PPC
BOOST_ARCH	:= power
endif

# they reinvent their own wheel^Hmake: jam
# -q: quit on error
# -d: debug level, default=1
BOOST_JAM	:= \
	$(BOOST_DIR)/b2 \
	--ignore-site-config \
	--user-config=user-config.jam \
	-q \
	$$(if $$(filter 0,$$(PTXDIST_VERBOSE)),-d0) \
	--layout=system \
	-sNO_BZIP2=0 \
	-sZLIB_INCLUDE=$(SYSROOT)/usr/include \
	-sZLIB_LIBPATH=$(SYSROOT)/usr/lib \
	variant=release \
	debug-symbols=on \
	threading=multi \
	link=static \
	cxxflags=-fPIC \
	toolset=gcc-$(PTXCONF_ARCH_STRING) \
	target-os=linux \
	abi=$(BOOST_ABI) \
	binary-format=elf \
	architecture=$(BOOST_ARCH) \
	address-model=$(call ptx/ifdef, PTXCONF_ARCH_LP64,64,32) \
	boost.locale.icu=off \
	$(addprefix --with-,$(BOOST_LIBRARIES-y))

JAM_PAR		:= \
	$(filter -j%,$(if $(PTXDIST_PARALLELMFLAGS),$(PTXDIST_PARALLELMFLAGS),$(PARALLELMFLAGS)))

# Use '=' to delay $(shell ...) calls until this is needed
JAM_MAKE_OPT	= \
	$(if $(shell test $(subst -j,,$(JAM_PAR)) -le 64 && echo 1),$(JAM_PAR),-j64) \
	stage

JAM_INSTALL_OPT	:= \
	install

$(STATEDIR)/boost.prepare:
	@$(call targetinfo)
	cd $(BOOST_DIR) && ./bootstrap.sh $(BOOST_CONF_OPT)
	@echo "using gcc : $(PTXCONF_ARCH_STRING) : $(CROSS_CXX) ;" > $(BOOST_DIR)/user-config.jam
ifdef PTXCONF_BOOST_MPI
	@echo "using mpi ;" >> $(BOOST_DIR)/user-config.jam
endif

ifdef PTXCONF_BOOST_PYTHON3
	@echo "using python : $(PYTHON3_MAJORMINOR) : $(PTXDIST_SYSROOT_CROSS)/bin/python : $(SYSROOT)/usr/include/python$(PYTHON3_MAJORMINOR)m : $(SYSROOT)/usr/lib/python$(PYTHON3_MAJORMINOR) ;" >> $(BOOST_DIR)/user-config.jam
endif
ifdef PTXCONF_BOOST_PYTHON2
	@echo "using python : $(PYTHON_MAJORMINOR) : $(PTXDIST_SYSROOT_CROSS)/bin/python : $(SYSROOT)/usr/include/python$(PYTHON_MAJORMINOR)m : $(SYSROOT)/usr/lib/python$(PYTHON_MAJORMINOR) ;" >> $(BOOST_DIR)/user-config.jam
endif

	@echo "all:"					>  $(BOOST_DIR)/Makefile
	@echo '	@$(BOOST_JAM) $(JAM_MAKE_OPT)'		>> $(BOOST_DIR)/Makefile
	@echo "install:"				>> $(BOOST_DIR)/Makefile
	@echo '	@$(BOOST_JAM) $(JAM_INSTALL_OPT)'	>> $(BOOST_DIR)/Makefile
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

# date_time is append to libraries list as minimum, however we only install it
# to target if it is really selected
ifndef PTXCONF_BOOST_DATE_TIME
BOOST_INST_LIBRARIES := $(filter-out date_time,$(BOOST_LIBRARIES-y))
else
BOOST_INST_LIBRARIES := $(BOOST_LIBRARIES-y)
endif

$(STATEDIR)/boost.targetinstall:
	@$(call targetinfo)

ifdef PTXCONF_BOOST_LIBS
	@$(call install_init, boost)
	@$(call install_fixup, boost,PRIORITY,optional)
	@$(call install_fixup, boost,SECTION,base)
	@$(call install_fixup, boost,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, boost,DESCRIPTION,missing)

	@$(call install_glob, boost, 0, 0, -, /usr/lib, */libboost*.so*)

	@$(call install_finish, boost)
endif

	@$(call touch)

# vim: syntax=make
