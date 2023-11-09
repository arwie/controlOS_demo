# -*-makefile-*-
#
# Copyright (C) 2023 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_GUI_JQUERY) += gui-jquery

#
# Paths and names
#
GUI_JQUERY_VERSION	:= 3.7.1
GUI_JQUERY_MD5		:= 2c872dbe60f4ba70fb85356113d8b35e
GUI_JQUERY		:= jquery-$(GUI_JQUERY_VERSION).min.js
GUI_JQUERY_URL		:= https://code.jquery.com/$(GUI_JQUERY)
GUI_JQUERY_SOURCE	:= $(SRCDIR)/$(GUI_JQUERY)
GUI_JQUERY_LICENSE	:= MIT

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-jquery.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-jquery.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-jquery.targetinstall:
	@$(call targetinfo)
	@$(call install_init, gui-jquery)
	@$(call install_fixup, gui-jquery,PRIORITY,optional)
	@$(call install_fixup, gui-jquery,SECTION,base)
	@$(call install_fixup, gui-jquery,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, gui-jquery,DESCRIPTION,missing)

	@$(call install_copy, gui-jquery, 0, 0, 0644, \
		$(GUI_JQUERY_SOURCE), /usr/lib/gui/static/jquery.js)

	@$(call install_finish, gui-jquery)
	@$(call touch)

# vim: syntax=make
