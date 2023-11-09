# -*-makefile-*-
#
# Copyright (C) 2016 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3_TORNADO) += python3-tornado

PYTHON3_TORNADO_VERSION	:= 6.3.2
PYTHON3_TORNADO_MD5	:= cabfe39cb7eb09d8128d4ac3deb934ce
PYTHON3_TORNADO		:= tornado-$(PYTHON3_TORNADO_VERSION)
PYTHON3_TORNADO_SUFFIX	:= tar.gz
PYTHON3_TORNADO_URL	:= $(call ptx/mirror-pypi, tornado, $(PYTHON3_TORNADO).$(PYTHON3_TORNADO_SUFFIX))
PYTHON3_TORNADO_SOURCE	:= $(SRCDIR)/$(PYTHON3_TORNADO).$(PYTHON3_TORNADO_SUFFIX)
PYTHON3_TORNADO_DIR	:= $(BUILDDIR)/$(PYTHON3_TORNADO)
PYTHON3_TORNADO_LICENSE	:= Apache-2.0
PYTHON3_TORNADO_LICENSE_FILES:= \
	file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_TORNADO_CONF_TOOL    := python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-tornado.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-tornado)
	@$(call install_fixup,python3-tornado,PRIORITY,optional)
	@$(call install_fixup,python3-tornado,SECTION,base)
	@$(call install_fixup,python3-tornado,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup,python3-tornado,DESCRIPTION,missing)

	@$(call install_glob, python3-tornado, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES)/tornado,, *.py)

	@$(call install_finish,python3-tornado)

	@$(call touch)

# vim: syntax=make
