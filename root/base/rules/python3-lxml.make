# -*-makefile-*-
#
# Copyright (C) 2018 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3_LXML) += python3-lxml

PYTHON3_LXML_VERSION	:= 4.4.2
PYTHON3_LXML_MD5	:= 235c1a22d97a174144e76b66ce62ae46
PYTHON3_LXML		:= lxml-$(PYTHON3_LXML_VERSION)
PYTHON3_LXML_SUFFIX	:= tar.gz
PYTHON3_LXML_URL	:= https://files.pythonhosted.org/packages/source/l/lxml/$(PYTHON3_LXML).$(PYTHON3_LXML_SUFFIX)
PYTHON3_LXML_SOURCE	:= $(SRCDIR)/$(PYTHON3_LXML).$(PYTHON3_LXML_SUFFIX)
PYTHON3_LXML_DIR	:= $(BUILDDIR)/$(PYTHON3_LXML)
PYTHON3_LXML_LICENSE	:= BSD

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_LXML_CONF_TOOL    := python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-lxml.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-lxml)
	@$(call install_fixup,python3-lxml,PRIORITY,optional)
	@$(call install_fixup,python3-lxml,SECTION,base)
	@$(call install_fixup,python3-lxml,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup,python3-lxml,DESCRIPTION,missing)

	@$(call install_glob, python3-lxml, 0, 0, -, \
		/usr/lib/python$(PYTHON3_MAJORMINOR)/site-packages/lxml,, *.py)

	@$(call install_finish,python3-lxml)

	@$(call touch)

# vim: syntax=make
