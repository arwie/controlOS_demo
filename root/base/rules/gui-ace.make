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
PACKAGES-$(PTXCONF_GUI_ACE) += gui-ace

#
# Paths and names
#
GUI_ACE_VERSION		:= 1.41.0
GUI_ACE_MD5		:= e4965a7d7165457fc87b36e0f58ddc2c
GUI_ACE			:= ace-$(GUI_ACE_VERSION)
GUI_ACE_SUFFIX		:= zip
GUI_ACE_URL		:= https://github.com/ajaxorg/ace-builds/archive/refs/tags/v$(GUI_ACE_VERSION).$(GUI_ACE_SUFFIX)
GUI_ACE_SOURCE		:= $(SRCDIR)/$(GUI_ACE).$(GUI_ACE_SUFFIX)
GUI_ACE_DIR		:= $(BUILDDIR)/$(GUI_ACE)
GUI_ACE_LICENSE		:= BSD-3-Clause

GUI_ACE_INSTALL		:= /usr/lib/gui/ace

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

GUI_ACE_MODES = $(call remove_quotes, $(PTXCONF_GUI_ACE_MODES))

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-ace.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-ace.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-ace.targetinstall:
	@$(call targetinfo)
	@$(call install_init, gui-ace)
	@$(call install_fixup, gui-ace,PRIORITY,optional)
	@$(call install_fixup, gui-ace,SECTION,base)
	@$(call install_fixup, gui-ace,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, gui-ace,DESCRIPTION,missing)

	@$(call install_copy, gui-ace, 0, 0, 0644, \
		$(GUI_ACE_DIR)/src-min-noconflict/ace.js, $(GUI_ACE_INSTALL)/index.js)

	@$(foreach mode, $(GUI_ACE_MODES), \
		$(call install_copy, gui-ace, 0, 0, 0644, \
			$(GUI_ACE_DIR)/src-min-noconflict/mode-$(mode).js, $(GUI_ACE_INSTALL)/mode-$(mode).js) \
	$(ptx/nl))

	@$(call install_finish, gui-ace)
	@$(call touch)

# vim: syntax=make
