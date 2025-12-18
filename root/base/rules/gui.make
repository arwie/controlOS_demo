# -*-makefile-*-
#
# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

#
# We provide this package
#
PACKAGES-$(PTXCONF_GUI) += gui

GUI_VERSION	:= 1
GUI_SRC		:= $(PTXDIST_WORKSPACE)/../code/gui

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui.targetinstall: $(shell find $(GUI_SRC) -type d)
	@$(call targetinfo)
	@$(call install_init, gui)

	@$(call install_tree, gui, 0, 0, \
		$(GUI_SRC), /usr/lib/gui)

	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/gui-hmi.service)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/gui-hmi.socket)
	@$(call install_link,        gui, ../gui-hmi.socket, /usr/lib/systemd/system/sockets.target.wants/gui-hmi.socket)

	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/gui-admin.service)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/gui-admin.socket)

	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/gui-studio.service)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/gui-studio.socket)

ifdef PTXCONF_GUI_WPEWEBKIT
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/udev/rules.d/60-drm-systemd.rules)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/weston.service)
	@$(call install_alternative, gui, 0, 0, 0644, /etc/cog.conf)
	@$(call install_alternative, gui, 0, 0, 0644, /etc/tmpfiles.d/fontconfig.conf)
	@$(call install_alternative, gui, 0, 0, 0644, /usr/lib/systemd/system/cog.service)
	@$(call install_link,        gui, ../cog.service, /usr/lib/systemd/system/multi-user.target.wants/cog.service)
endif

	@$(call install_finish,gui)
	@$(call touch)


# vim: syntax=make
