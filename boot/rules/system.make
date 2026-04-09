# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

#
# We provide this package
#
PACKAGES-$(PTXCONF_SYSTEM) += system

SYSTEM_VERSION	:= 1
SYSTEM_LICENSE	:= ignore

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/system.targetinstall:
	@$(call targetinfo)
	@$(call install_init, system)

	@$(foreach mnt, install boot root data, \
		$(call install_copy, system, 0, 0, 0755, /mnt/$(mnt)); \
	)

	@$(call install_alternative, system, 0, 0, 0644, /init.inc)
	@$(call install_alternative, system, 0, 0, 0644, /init.board)
	@$(call install_alternative, system, 0, 0, 0755, /init)

	@$(call install_alternative, system, 0, 0, 0644, /boot.board)
	@$(call install_alternative, system, 0, 0, 0755, /boot)

	@$(call install_alternative, system, 0, 0, 0644, /install.board)
	@$(call install_alternative, system, 0, 0, 0755, /install)

	@$(call install_finish, system)
	@$(call touch)

# vim: syntax=make
