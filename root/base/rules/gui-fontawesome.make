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
PACKAGES-$(PTXCONF_GUI_FONTAWESOME) += gui-fontawesome

#
# Paths and names
#
GUI_FONTAWESOME_VERSION		:= 6.7.2
GUI_FONTAWESOME_MD5		:= dddf173753a66f5a364314660d84fd18
GUI_FONTAWESOME			:= fontawesome-free-$(GUI_FONTAWESOME_VERSION)-web
GUI_FONTAWESOME_SUFFIX		:= zip
GUI_FONTAWESOME_URL		:= https://use.fontawesome.com/releases/v$(GUI_FONTAWESOME_VERSION)/$(GUI_FONTAWESOME).$(GUI_FONTAWESOME_SUFFIX)
GUI_FONTAWESOME_SOURCE		:= $(SRCDIR)/$(GUI_FONTAWESOME).$(GUI_FONTAWESOME_SUFFIX)
GUI_FONTAWESOME_DIR		:= $(BUILDDIR)/$(GUI_FONTAWESOME)
GUI_FONTAWESOME_LICENSE		:= CC-BY-4.0 AND OFL-1.1 AND MIT
GUI_FONTAWESOME_LICENSE_FILES	:= file://LICENSE.txt;md5=4186e0f8172f263065437f80932efbe1

GUI_FONTAWESOME_INSTALL		:= /usr/lib/gui/fontawesome

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-fontawesome.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-fontawesome.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-fontawesome.targetinstall:
	@$(call targetinfo)
	@$(call install_init, gui-fontawesome)
	@$(call install_fixup, gui-fontawesome,PRIORITY,optional)
	@$(call install_fixup, gui-fontawesome,SECTION,base)
	@$(call install_fixup, gui-fontawesome,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, gui-fontawesome,DESCRIPTION,missing)

	@$(call install_copy, gui-fontawesome, 0, 0, 0644, \
		$(GUI_FONTAWESOME_DIR)/css/all.min.css, \
		$(GUI_FONTAWESOME_INSTALL)/css/all.css)
	@$(call install_tree, gui-fontawesome, 0, 0, \
		$(GUI_FONTAWESOME_DIR)/webfonts, \
		$(GUI_FONTAWESOME_INSTALL)/webfonts)

	@$(call install_finish, gui-fontawesome)
	@$(call touch)

# vim: syntax=make
