# -*-makefile-*-
#
# Copyright (C) 2016 by Artur Wiebe <artur@4wiebe.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3_TORNADO) += python3-tornado

PYTHON3_TORNADO_VERSION	:= 6.0.3
PYTHON3_TORNADO_MD5	:= cab4b11480f6d032e46465586192d343
PYTHON3_TORNADO		:= tornado-$(PYTHON3_TORNADO_VERSION)
PYTHON3_TORNADO_SUFFIX	:= tar.gz
PYTHON3_TORNADO_URL	:= https://files.pythonhosted.org/packages/source/t/tornado/$(PYTHON3_TORNADO).$(PYTHON3_TORNADO_SUFFIX)
PYTHON3_TORNADO_SOURCE	:= $(SRCDIR)/$(PYTHON3_TORNADO).$(PYTHON3_TORNADO_SUFFIX)
PYTHON3_TORNADO_DIR	:= $(BUILDDIR)/$(PYTHON3_TORNADO)
PYTHON3_TORNADO_LICENSE	:= Apache-2.0

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
		/usr/lib/python$(PYTHON3_MAJORMINOR)/site-packages/tornado,, *.py)

	@$(call install_finish,python3-tornado)

	@$(call touch)

# vim: syntax=make
